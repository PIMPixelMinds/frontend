import { BadRequestException, ConflictException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { SignUpDto } from './dto/signUp.dto';
import { InjectModel } from '@nestjs/mongoose';
import { User } from './schema/user.schema';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { LoginDto } from './dto/login.dto';
import { ResetCode } from './schema/reset-password.schema';
import { MailService } from 'src/service/mail.service';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { EditProfileDto } from './dto/edit-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { randomBytes } from 'crypto';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';

@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;
  constructor(
    @InjectModel(User.name)
    private userModel: Model<User>,
    private jwtService: JwtService,
    @InjectModel(ResetCode.name)
    private ResetCodeModel: Model<ResetCode>,
    private mailService: MailService,
    private configService: ConfigService, 
  ) {
    this.googleClient = new OAuth2Client(
      this.configService.get<string>('GOOGLE_CLIENT_ID'),
    );
  }

  async signUp(signUpDto: SignUpDto): Promise<{ user }> {
    const { fullName, email, birthday, password, gender, phone, profileCompleted, careGiverEmail, diagnosis, type, medicalReport } = signUpDto;

    const existingUser = await this.userModel.findOne({ email });
    if (existingUser) {
      throw new ConflictException('Email is already registered');
    }

    const initializedProfileCompleted = profileCompleted ?? false;
    const hashedPassword = await bcrypt.hash(password, 10);
    const initializedType = type ?? false;
    const initializedBirthday = birthday ?? new Date('2000-02-20');
    const initializedPhone = phone ?? 10000000;
    const initializedCareGiverEmail = careGiverEmail ?? '';
    const initializedDiagnosis = diagnosis ?? '';

    const user = await this.userModel.create({
      fullName,
      email,
      birthday: initializedBirthday,
      password: hashedPassword,
      gender: gender ? 'male' : 'female',
      phone: initializedPhone,
      profileCompleted: initializedProfileCompleted,
      careGiverEmail: initializedCareGiverEmail,
      diagnosis: initializedDiagnosis,
      type: initializedType,
      medicalReport,
    });

    return { user };
  }

  async login(email: string, password: string): Promise<{ accessToken: string; refreshToken: string }> {
    const user = await this.userModel.findOne({ email }).exec();
    if (!user || !(await bcrypt.compare(password, user.password))) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = {
      userId: user.id.toString(),
      fullName: user.fullName,
      email: user.email,
      gender: user.gender,
      birthday: user.birthday,
    };

    const accessToken = this.jwtService.sign(payload, { expiresIn: '5m' });
    const refreshToken = randomBytes(32).toString('hex'); // Générer un refresh token unique
    user.refreshToken = refreshToken; // Stocker dans la base de données
    await user.save();

    return { accessToken, refreshToken };
  }

  async refreshToken(refreshToken: string): Promise<{ payload: any; newAccessToken: string; newRefreshToken: string }> {
    try {
      const user = await this.userModel.findOne({ refreshToken }).exec();
      if (!user) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      // Générer un nouveau access token et refresh token
      const payload = {
        userId: user.id.toString(),
        fullName: user.fullName,
        email: user.email,
        gender: user.gender,
        birthday: user.birthday,
      };

      const newAccessToken = this.jwtService.sign(payload, { expiresIn: '5m' });
      const newRefreshToken = randomBytes(32).toString('hex'); // Nouveau refresh token
      user.refreshToken = newRefreshToken; // Mettre à jour dans la base de données
      await user.save();

      return { payload, newAccessToken, newRefreshToken };
    } catch (e) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }

  async validateGoogleUser(googleUser: any): Promise<any> {
    const { email, fullName, gender, birthday, googleId, accessToken, refreshToken } = googleUser;
  
    let user = await this.userModel.findOne({ email }) || await this.userModel.findOne({ googleId });
  
    if (user) {
      if (!user.googleId) {
        user.googleId = googleId;
        user.accessToken = accessToken;
        user.refreshToken = refreshToken;
        await user.save();
      }
      return user;
    }
  
    // Generate a random password for the Google user
    const randomPassword = randomBytes(16).toString('hex'); // 32-character hex string
    const hashedPassword = await bcrypt.hash(randomPassword, 10);
  
    const newUser = await this.userModel.create({
      fullName,
      email,
      password: hashedPassword, // Store the hashed random password
      gender,
      birthday,
      googleId,
      accessToken,
      refreshToken,
      profileCompleted: false,
      phone: 10000000,
      careGiverEmail: '',
      diagnosis: '',
      type: false,
      medicalReport: '',
    });
  
    
  
    return newUser;
  }

  async validateGoogleToken(token: string): Promise<any> {
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken: token,
        audience: this.configService.get<string>('GOOGLE_CLIENT_ID'),
      });
      const payload = ticket.getPayload();

      if (!payload) {
        throw new UnauthorizedException('Invalid Google token');
      }

      const { email, name, sub: googleId } = payload;
      const user = {
        email,
        fullName: name,
        googleId,
        gender: '', // À compléter si besoin
        birthday: new Date('2000-02-20'), // Valeur par défaut
        accessToken: token,
      };

      return this.validateGoogleUser(user);
    } catch (error) {
      throw new UnauthorizedException('Google token validation failed');
    }
  }
  async googleLogin(user: any): Promise<{ payload, token: string }> {
    const payload = {
      userId: user._id.toString(),
      fullName: user.fullName,
      email: user.email,
      gender: user.gender,
      birthday: user.birthday,
      phone: user.phone,
      careGiverEmail: user.careGiverEmail,
      diagnosis: user.diagnosis,
      medicalReport: user.medicalReport
    };

    const token = this.jwtService.sign(payload, { expiresIn: '5m' });

    return { payload, token };
  }

  async forgotPassword(email: string) {
    const user = await this.userModel.findOne({ email });
    if (!user) throw new UnauthorizedException("Invalid Email.");

    const resetCode = Math.floor(100000 + Math.random() * 900000);
    const expiryDate = new Date();
    expiryDate.setSeconds(expiryDate.getMinutes() + 100);

    await this.ResetCodeModel.create({
      codeNumber: resetCode,
      userId: user._id,
      expiryDate,
    });

    await this.mailService.sendPasswordResetEmail(email, resetCode);

    return { message: "Reset code sent to your email.", state: "success" };
  }

  async getResetCodeByEmail(email: string): Promise<ResetCode> {
    const user = await this.userModel.findOne({ email });
    if (!user) throw new NotFoundException('User not found');

    const resetCode = await this.ResetCodeModel.findOne({
      userId: user._id,
      expiryDate: { $gt: new Date() }
    });

    if (!resetCode) throw new NotFoundException('Code not found or expired');
    return resetCode;
  }

  async verifyResetCode(email: string, resetCode: string): Promise<boolean> {
    const user = await this.userModel.findOne({ email });
    if (!user) throw new NotFoundException('User not found');

    const codeRecord = await this.ResetCodeModel.findOne({
      userId: user._id,
      codeNumber: resetCode,
      expiryDate: { $gt: new Date() }
    });

    return !!codeRecord;
  }

  async changePassword(email: string, changePasswordDto: ResetPasswordDto): Promise<void> {
    const user = await this.userModel.findOne({ email });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const hashedPassword = await bcrypt.hash(changePasswordDto.newPassword, 10);
    await this.userModel.updateOne({ email }, { password: hashedPassword });
  }

  async getProfile(user: any) {
    const foundUser = await this.userModel.findById(user.userId);
    if (!foundUser) {
      throw new NotFoundException('User not found');
    }

    const { password, ...safeUser } = foundUser.toObject();

    return safeUser;
  }

  async updateProfile(id: string, editProfileDto: EditProfileDto): Promise<{ user }> {
    const { newName, newEmail, newBirthday, newGender, newPhone, newCareGiverEmail, newDiagnosis, newMedicalReport } = editProfileDto;

    const findUser = await this.userModel.findById(id);

    if (!findUser) {
      throw new NotFoundException('User not found');
    }

    if (newName == findUser.fullName) {
      throw new BadRequestException('That is already your Full Name');
    }

    if (newEmail && newEmail !== findUser.email) {
      const existingUser = await this.userModel.findOne({ email: newEmail });
      if (existingUser) {
        throw new BadRequestException('Email already exists');
      }
    }

    const updateData: any = {};
    if (newName) {
      updateData.fullName = newName;
    }
    if (newEmail) {
      updateData.email = newEmail;
    }
    if (newBirthday) {
      updateData.birthday = newBirthday;
    }
    if (newGender) {
      updateData.gender = newGender;
    }
    if (newPhone) {
      updateData.phone = newPhone;
    }
    if (newCareGiverEmail) {
      updateData.careGiverEmail = newCareGiverEmail;
    }
    if (newDiagnosis) {
      updateData.diagnosis = newDiagnosis;
    }
    if (newMedicalReport) {
      updateData.medicalReport = newMedicalReport;
    }

    const updatedUser = await this.userModel.findOneAndUpdate(
      { _id: id },
      { $set: updateData },
      { new: true }
    );

    return { user: updatedUser };
  }

  async updatePassword(id: string, changePasswordDto: ChangePasswordDto): Promise<{ user }> {
    const { oldPassword, newPassword } = changePasswordDto;

    const findUser = await this.userModel.findById(id);
    if (!findUser) {
      throw new NotFoundException('User not found');
    }

    //Compare passwords
    const passwordMatch = await bcrypt.compare(oldPassword, findUser.password)
    if (!passwordMatch) {
      throw new NotFoundException('Check your current password');
    }

    //Create new password
    const newHashedPassword = await bcrypt.hash(newPassword, 10);
    findUser.password = newHashedPassword;

    await findUser.save()
    const userAfterPasswordUpdate = await this.userModel.findById(id)
    return { user: userAfterPasswordUpdate };

  }

  async deleteProfile(id: string): Promise<{ message: string }> {
    const findUser = await this.userModel.findById(id);
    if (!findUser) {
      throw new NotFoundException('User not found');
    }
    await findUser.deleteOne()
    return { message: "Profile has been deleted !" };
  }

}

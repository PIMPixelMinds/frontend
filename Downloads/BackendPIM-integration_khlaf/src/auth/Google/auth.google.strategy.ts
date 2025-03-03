import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service'; // Corrected import path

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    const clientID = configService.get<string>('GOOGLE_CLIENT_ID');
    const clientSecret = configService.get<string>('GOOGLE_CLIENT_SECRET');

    if (!clientID || !clientSecret) {
      throw new Error('Google OAuth credentials (CLIENT_ID and CLIENT_SECRET) are not configured in .env');
    }

    super({
      clientID,
      clientSecret,
      callbackURL: 'http://localhost:3000/auth/google/redirect',
      scope: ['email', 'profile'],
      passReqToCallback: true, // Required for StrategyOptionsWithRequest
    });
  }

  async validate(
    req: any,
    accessToken: string,
    refreshToken: string,
    profile: any,
    done: VerifyCallback,
  ): Promise<any> {
    // You can add logic here to handle the prompt dynamically if needed
    const { name, emails } = profile;
    const user = {
      email: emails[0].value,
      fullName: `${name.givenName} ${name.familyName}`,
      gender: '', // You can add logic to infer gender if needed, or leave it empty
      birthday: new Date('2000-02-20'), // Default birthday (you can update this later via profile or user input)
      googleId: profile.id,
      accessToken,
      refreshToken,
    };

    const existingUser = await this.authService.validateGoogleUser(user);
    done(null, existingUser || user);
  }
}
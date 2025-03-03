import { IsBoolean, IsDate, IsEmail, IsNotEmpty, IsNumber, IsOptional, IsString, MinLength } from "class-validator";

export class EditProfileDto {

    @IsOptional()
    @IsString()
    newName: string;

    @IsOptional()
    @IsEmail()
    newEmail: string;

    @IsOptional()
    @IsDate()
    newBirthday: Date;

    @IsOptional()
    @IsBoolean()
    newGender: boolean;

    @IsOptional()
    @IsNumber()
    newPhone: number;

    @IsOptional()
    @IsEmail()
    newCareGiverEmail: string;

    @IsOptional()
    @IsEmail()
    newDiagnosis: string;

    @IsOptional()
    @IsString()
    newMedicalReport: string
}
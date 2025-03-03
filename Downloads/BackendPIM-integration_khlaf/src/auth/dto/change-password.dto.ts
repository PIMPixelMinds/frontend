import { IsDate, IsEmail, IsNotEmpty, IsNumber, IsString, MinLength } from "class-validator";

export class ChangePasswordDto {

    @IsString()
    oldPassword: string;

    @IsString()
    newPassword: string;

}
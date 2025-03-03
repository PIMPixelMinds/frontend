import { IsDate, IsEmail, IsNotEmpty, IsNumber, IsString, MinLength } from "class-validator";

export class VerifyCodeDto {

    @IsEmail()
    email: string;

    @IsNotEmpty()
    @IsString()
    resetCode: string;

}
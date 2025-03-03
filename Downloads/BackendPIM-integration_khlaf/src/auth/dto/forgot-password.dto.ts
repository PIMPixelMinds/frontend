import { IsEmail, IsNotEmpty, IsString, MinLength } from "class-validator";

export class ForgotPasswordDto {

    @IsNotEmpty()
    @IsEmail({}, {message: "Please enter the correct email form."})
    email: string;

}
import { IsEmail, IsNotEmpty, IsString, MinLength } from "class-validator";

export class LoginDto {

    @IsNotEmpty()
    @IsEmail({}, {message: "Please enter the correct email form."})
    email: string;

    @IsNotEmpty()
    @IsString()
    password: string;

}
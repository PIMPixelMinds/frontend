import { IsString, Matches, MinLength } from "class-validator";

export class ResetPasswordDto {

    @IsString()
    @MinLength(6)
    @Matches(/^(?=.*[0-9])/, { message: "Password must contain at least 1 number." })
    newPassword: string;

}
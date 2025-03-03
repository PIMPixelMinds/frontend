import { IsBoolean, IsDate, IsEmail, IsNotEmpty, IsNumber, IsOptional, IsString, MinLength } from "class-validator";

export class EditAppointmentDto {

    @IsOptional()
    @IsString()
    newFullName: string;

    @IsOptional()
    @IsDate()
    newDate: Date

    @IsOptional()
    @IsString()
    newPhone: string

}
import { IsString, IsNumber, Min, IsEnum, IsOptional, IsBoolean, IsNotEmpty } from 'class-validator';

export class CreateMedicationDto {
  @IsString()
  @IsNotEmpty()
  name: string; // e.g., "Rivastigmine"

  @IsNumber()
  @Min(0)
  amount: number; // Numeric value (e.g., 2 for "2 Pill/Day")

  @IsString()
  @IsNotEmpty()
  unit: string; // Unit of the amount (e.g., "Pill")

  @IsString()
  @IsNotEmpty()
  duration: string; // Duration of the medication (e.g., "1 Month")

  @IsString()
  @IsNotEmpty()
  capSize: string; // Cap size (e.g., "150mg 1 Capsule")

  @IsString()
  @IsNotEmpty()
  cause: string; // Reason for taking the medication (e.g., "Alzheimer's")

  @IsEnum(['Daily', 'Weekly', 'Monthly', 'As Needed'])
  frequency: string; // e.g., "Daily"

  @IsEnum(['Before Breakfast', 'After Breakfast', 'Before Lunch', 'After Lunch', 'Before Dinner', 'After Dinner', 'Before Meals', 'After Meals'])
  schedule: string; // Time of day to take the medication (e.g., "Before Breakfast")

  @IsOptional()
  @IsBoolean()
  isActive?: boolean; // Optional, defaults to true if not specified

  @IsOptional()
  @IsString()
  photoUrl?: string; // Optional URL or path to the photo of the medication
}
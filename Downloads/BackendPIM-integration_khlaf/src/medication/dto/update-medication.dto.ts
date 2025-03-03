import { IsString, IsNumber, Min, IsEnum, IsOptional, IsBoolean } from 'class-validator';

export class UpdateMedicationDto {
  @IsOptional()
  @IsString()
  name?: string; // e.g., "Rivastigmine"

  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number; // Numeric value (e.g., 2 for "2 Pill/Day")

  @IsOptional()
  @IsString()
  unit?: string; // Unit of the amount (e.g., "Pill")

  @IsOptional()
  @IsString()
  duration?: string; // Duration of the medication (e.g., "1 Month")

  @IsOptional()
  @IsString()
  capSize?: string; // Cap size (e.g., "150mg 1 Capsule")

  @IsOptional()
  @IsString()
  cause?: string; // Reason for taking the medication (e.g., "Alzheimer's")

  @IsOptional()
  @IsEnum(['Daily', 'Weekly', 'Monthly', 'As Needed'])
  frequency?: string; // e.g., "Daily"

  @IsOptional()
  @IsEnum(['Before Breakfast', 'After Breakfast', 'Before Lunch', 'After Lunch', 'Before Dinner', 'After Dinner', 'Before Meals', 'After Meals'])
  schedule?: string; // Time of day to take the medication (e.g., "Before Breakfast")

  @IsOptional()
  @IsBoolean()
  isActive?: boolean; // Whether the reminder is active

  @IsOptional()
  @IsString()
  photoUrl?: string; // Optional URL or path to the photo of the medication
}
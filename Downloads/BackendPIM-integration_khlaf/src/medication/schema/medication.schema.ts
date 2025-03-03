import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types, Document } from 'mongoose';

@Schema({
  timestamps: true, // Automatically adds createdAt and updatedAt fields
})
export class Medication extends Document {
  @Prop({ required: true })
  name: string; // e.g., "Rivastigmine"

  @Prop({ required: true, type: Number, min: 0 })
  amount: number; // Numeric value (e.g., 2 for "2 Pill/Day")

  @Prop({
    required: true,
    enum: ['Pill', 'mg', 'mL'],
    default: 'Pill',
  })
  unit: string; // Unit of the amount (e.g., "Pill")

  @Prop({
    required: true,
    enum: ['1 Month', '2 Months', '3 Months', 'Ongoing'],
    default: '1 Month',
  })
  duration: string; // Duration of the medication (e.g., "1 Month")

  @Prop({ required: true })
  capSize: string; // Cap size (e.g., "150mg 1 Capsule")

  @Prop({ required: true })
  cause: string; // Reason for taking the medication (e.g., "Alzheimer's")

  @Prop({
    required: true,
    enum: ['Daily', 'Weekly', 'Monthly', 'As Needed'],
    default: 'Daily',
  })
  frequency: string; // e.g., "Daily"

  @Prop({
    required: true,
    // enum: [
    //   'Before Breakfast',
    //   'After Breakfast',
    //   'Before Lunch',
    //   'After Lunch',
    //   'Before Dinner',
    //   'After Dinner',
    //   'Before Meals',
    //   'After Meals',
    // ],
    // default: 'Before Breakfast',
  })
  schedule: string; // Time of day to take the medication (e.g., "Before Breakfast")

  @Prop({ required: true, default: true })
  isActive: boolean; // Whether the reminder is active

  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId: Types.ObjectId; // Reference to the user who owns this medication

  @Prop({ type: String, required: false })
  photoUrl?: string; // URL or path to the photo of the medication (optional)

  // createdAt and updatedAt are automatically added by timestamps
}

export type MedicationDocument = Medication & Document;

export const MedicationSchema = SchemaFactory.createForClass(Medication);
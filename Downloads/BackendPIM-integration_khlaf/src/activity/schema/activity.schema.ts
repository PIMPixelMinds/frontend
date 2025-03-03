import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type ActivityDocument = Activity & Document;

@Schema({ timestamps: true }) // Enables createdAt and updatedAt
export class Activity {
  @Prop({ required: true })
  activity: string;

  @Prop({ required: true })
  description: string;
}

export const ActivitySchema = SchemaFactory.createForClass(Activity);

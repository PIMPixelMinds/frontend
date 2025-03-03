import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import * as mongoose from 'mongoose';

@Schema({
  versionKey: false,
  timestamps: true,
})
export class ResetCode extends Document {
  @Prop({ required: true })
  codeNumber: string;

  @Prop({ required: true, type: mongoose.Types.ObjectId })
  userId: mongoose.Types.ObjectId;

  @Prop({ required: true })
  expiryDate: Date;
}

export const ResetCodeSchema = SchemaFactory.createForClass(ResetCode);
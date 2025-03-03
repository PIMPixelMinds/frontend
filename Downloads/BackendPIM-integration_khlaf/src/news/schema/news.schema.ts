import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema()
export class News extends Document {
  @Prop() title: string;
  @Prop() link: string;
  @Prop() summary: string;
  @Prop() image: string;
  @Prop() date: Date;
}

export const NewsSchema = SchemaFactory.createForClass(News);

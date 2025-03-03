import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Schema as MongooseSchema, Types } from 'mongoose'; 
import { User } from 'src/auth/schema/user.schema';


@Schema({ timestamps: true })
export class Historique extends Document {
  @Prop({ required: true })
  imageUrl: string; // Lien de l’image capturée

  @Prop({ required: true })
  generatedDescription: string; // Description générée par l’IA

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  user: User; // Référence à l’utilisateur

}

export const HistoriqueSchema = SchemaFactory.createForClass(Historique);

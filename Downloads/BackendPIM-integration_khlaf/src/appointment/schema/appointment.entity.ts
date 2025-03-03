import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Types } from "mongoose";

@Schema({
    timestamps: true
})

export class Appointment {

    @Prop()
    fullName: string

    @Prop()
    date: Date

    @Prop()
    phone: string

    @Prop({ type: String, enum: ["Upcoming","Completed","Canceled"] })
    status: string

    @Prop()
    fcmToken: string
}

export const AppointmentSchema = SchemaFactory.createForClass(Appointment)
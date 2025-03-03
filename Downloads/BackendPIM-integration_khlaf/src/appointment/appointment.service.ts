import { Injectable, NotFoundException } from '@nestjs/common';

import { AddAppointmentDto } from './dto/addAppointment.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Appointment, AppointmentSchema } from './schema/appointment.entity';
import { Model } from 'mongoose';
import { EditAppointmentDto } from './dto/editAppointment.dto';
import { Cron } from '@nestjs/schedule';
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';



@Injectable()
export class AppointmentService {

  constructor(
    @InjectModel(Appointment.name)
    private appointmentModel: Model<Appointment>
  ) { }

  async addAppointment(addAppointmentDto: AddAppointmentDto): Promise<{ appointment }> {
    const { fullName, date, phone, status, fcmToken } = addAppointmentDto;

    const initializedStatus = status ?? false;
    const initializedFcmToken = fcmToken ?? "";

    const appointment = await this.appointmentModel.create({
      fullName,
      date,
      phone,
      status: initializedStatus ? "Past " : "Upcoming",
      fcmToken: initializedFcmToken
    });

    return { appointment }

  }

  async updateAppointment(appointmentName: string, editAppointmentDto: EditAppointmentDto): Promise<{ appointment }> {
    const { newFullName, newDate, newPhone } = editAppointmentDto;

    const findAppointment = await this.appointmentModel.findOne({ fullName: appointmentName });

    if (!findAppointment) {
      throw new NotFoundException("No such appointment exist !");
    }

    const newAppointment: any = {};
    if (newFullName) {
      newAppointment.fullName = newFullName
    }
    if (newDate) {
      newAppointment.date = newDate
    }
    if (newPhone) {
      newAppointment.phone = newPhone
    }

    const updatedAppointment = await this.appointmentModel.findOneAndUpdate(
      { fullName: findAppointment.fullName },
      { $set: newAppointment },
      { new: true }
    )

    return { appointment: updatedAppointment }

  }

  async cancelAppointment(appointmentName: string): Promise<{ message: string }> {

    const findAppointment = await this.appointmentModel.findOne({ fullName: appointmentName });
    if (!findAppointment) {
      throw new NotFoundException('Appointment not found');
    }

    await findAppointment.updateOne({
      status: "Canceled",
    });

    return { message: "Appointment has been cancelled!" };
  }

  async displayAppointment(): Promise<{ appointment: Appointment[] }> {

    const findAppointment = await this.appointmentModel.find();

    for (const appointment of findAppointment) {
      if (new Date(appointment.date) < new Date()) {
        await this.appointmentModel.updateOne(
          { _id: appointment._id },
          { $set: { status: "Completed" } }
        );
      }
    }

    const updatedAppointments = await this.appointmentModel.find();
    return { appointment: updatedAppointments };

  }

  @Cron('0 * * * * *')
  async checkTodayAppointments() {
    const now = new Date();

    const today = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));

    const tomorrow = new Date(today);
    tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);

    const appointments = await this.appointmentModel.find({
      date: { $gte: today, $lt: tomorrow },
      status: "Upcoming",
    });


    for (const appointment of appointments) {
      if (appointment.fcmToken) {
        await this.sendNotification(appointment.fcmToken, appointment.fullName, appointment.date);
      }
    }
  }


  async sendNotification(fcmToken: string, fullName: string, date: Date) {
    const message = {
      notification: {
        title: "Appointment Reminder",
        body: `Hello There! Today you have an appointment with ${fullName}`,
      },
      token: fcmToken
    };

    try {
      await admin.messaging().send(message);
      console.log(`Notification sent for ${fullName} appointment`);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  }


  async updateFcmToken(fullName: string, fcmToken: string): Promise<{ message: string }> {
    const appointment = await this.appointmentModel.findOne({ fullName });

    if (!appointment) {
      throw new NotFoundException("Appointment not found!");
    }

    await this.appointmentModel.updateOne({ fullName }, { $set: { fcmToken } });

    return { message: "FCM Token updated successfully!" };
  }

  async countAppointments(): Promise<{ message: string }> {
    const findAppointment = await this.appointmentModel.find();

    let upcomingAppointments = 0;
    let canceledAppointments = 0;
    let completedAppointments = 0;

    for (const appointment of findAppointment) {
      if (appointment.status == "Upcoming") {
        upcomingAppointments++;
      } else if (appointment.status == "Canceled"){
        canceledAppointments++;
      } else {
        completedAppointments++;
      }
    }

    return { message: "Upcoming Appointments : "+upcomingAppointments+" | Canceled Appointments : "+canceledAppointments+" | Completed Appointments : "+completedAppointments };
  }

  async getCompletedAppointments(): Promise<{ appointment: Appointment[] }> {
    const completedAppointments = await this.appointmentModel
      .find({ status: "Completed" })
      .sort({ createdAt: -1 }) // Sort by most recent
      .limit(2); // Get only the latest 2
  
    return { appointment: completedAppointments };
  }
  
  
}

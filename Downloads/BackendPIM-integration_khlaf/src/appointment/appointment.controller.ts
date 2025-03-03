import { Controller, Get, Post, Body, Patch, Param, Delete, Request, UseGuards, Put } from '@nestjs/common';
import { AppointmentService } from './appointment.service';
import { AddAppointmentDto } from './dto/addAppointment.dto';
import { EditAppointmentDto } from './dto/editAppointment.dto';
import { Appointment } from './schema/appointment.entity';


@Controller('appointment')
export class AppointmentController {

  constructor(private readonly appointmentService: AppointmentService) { }

  @Post('addAppointment')
  AddAppointment(@Body() addAppointmentDto: AddAppointmentDto) {
    return this.appointmentService.addAppointment(addAppointmentDto);
  }

  @Put('updateAppointment/:appointmentName')
  UpdateAppointment(@Param('appointmentName') appointmentName: string, @Body() editAppointmentDto: EditAppointmentDto) {
    return this.appointmentService.updateAppointment(appointmentName, editAppointmentDto);
  }

  @Put('cancelAppointment/:appointmentName')
  async cancelAppointment(@Param('appointmentName') appointmentName: string): Promise<{ message: string }> {
    return this.appointmentService.cancelAppointment(appointmentName);
  }

  @Get('displayAppointment')
  displayAppointment(): Promise<{ appointment }> {
    return this.appointmentService.displayAppointment();
  }

  @Put('updateFcmToken')
  async updateFcmToken(@Body() body: { fullName: string, fcmToken: string }) {
    return this.appointmentService.updateFcmToken(body.fullName, body.fcmToken);
  }

  @Get('countAppointments')
  countAppointments(){
    return this.appointmentService.countAppointments();
  }
  @Get('completedAppointments')
async getCompletedAppointments(): Promise<{ appointment: Appointment[] }> {
  return this.appointmentService.getCompletedAppointments();
}


}

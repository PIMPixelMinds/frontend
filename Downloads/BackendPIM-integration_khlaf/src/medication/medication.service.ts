import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types, FilterQuery } from 'mongoose';
import { addMonths, startOfWeek, endOfWeek, startOfMonth, endOfMonth, startOfDay, endOfDay } from 'date-fns';
import { CreateMedicationDto } from './dto/create-medication.dto';
import { UpdateMedicationDto } from './dto/update-medication.dto';
import { Medication, MedicationDocument } from './schema/medication.schema';

// Définir un type pour une requête MongoDB valide sur createdAt
interface DateQuery {
  $gte?: Date;
  $lte?: Date;
  $exists?: boolean;
}

// Exporter l'interface ExtendedMedicationDocument
export interface ExtendedMedicationDocument extends MedicationDocument {
  createdAt?: Date;
  updatedAt?: Date;
}

@Injectable()
export class MedicationService {
  constructor(@InjectModel(Medication.name) private medicationModel: Model<ExtendedMedicationDocument>) {}

  async create(createMedicationDto: CreateMedicationDto, userId: string): Promise<ExtendedMedicationDocument> {
    const createdMedication = new this.medicationModel({
      ...createMedicationDto,
      userId: new Types.ObjectId(userId), // Ensure userId is converted to ObjectId
    });
    return createdMedication.save();
  }

  async update(id: string, updateMedicationDto: UpdateMedicationDto): Promise<ExtendedMedicationDocument | null> {
    return this.medicationModel
      .findByIdAndUpdate(id, updateMedicationDto, { new: true, runValidators: true, lean: true }) // lean: true for performance
      .exec();
  }

  async findAll(userId: string): Promise<ExtendedMedicationDocument[]> {
    return this.medicationModel
      .find({ userId: new Types.ObjectId(userId) })
      .lean() // Use lean() for better performance when only data is needed
      .exec() as unknown as ExtendedMedicationDocument[]; // Cast to ensure type compatibility
  }

  async findByScheduleRange(userId: string, filter: 'today' | 'week' | 'month'): Promise<ExtendedMedicationDocument[]> {
    const now = new Date();
    const userObjectId = new Types.ObjectId(userId);

    let dateQuery: FilterQuery<ExtendedMedicationDocument> = {
      userId: userObjectId,
      isActive: true,
      createdAt: { $exists: true }, // Initialiser avec $exists pour vérifier que createdAt existe
    };

    // Utiliser startOfDay et endOfDay de date-fns pour filtrer par période
    switch (filter.toLowerCase()) {
      case 'today':
        const startOfToday = startOfDay(now);
        const endOfToday = endOfDay(now);
        dateQuery.createdAt = { $gte: startOfToday, $lte: endOfToday };
        break;
      case 'week':
        const startOfWeekDate = startOfWeek(now);
        const endOfWeekDate = endOfWeek(now);
        dateQuery.createdAt = { $gte: startOfWeekDate, $lte: endOfWeekDate };
        break;
      case 'month':
        const startOfMonthDate = startOfMonth(now);
        const endOfMonthDate = endOfMonth(now);
        dateQuery.createdAt = { $gte: startOfMonthDate, $lte: endOfMonthDate };
        break;
      default:
        throw new BadRequestException('Invalid filter option. Use "today", "week", or "month"');
    }

    const medications = await this.medicationModel
      .find(dateQuery)
      .select('name amount unit duration capSize cause frequency schedule createdAt photoUrl userId isActive')
      .lean()
      .exec() as unknown as ExtendedMedicationDocument[];

    // Filtrer les médicaments qui sont dûs en fonction de schedule, frequency, et duration
    return medications.filter(medication => {
      return this.isMedicationDue(now, medication.schedule, medication.frequency) &&
             this.isMedicationActive(now, medication.duration, medication.createdAt);
    });
  }

  private isMedicationActive(now: Date, duration: string, createdAt: Date | undefined): boolean {
    if (!createdAt) {
      console.warn('createdAt is undefined for medication with duration:', duration);
      return false; // Skip medications without a createdAt
    }

    if (duration === 'Ongoing') return true;
    const durationMatch = duration.match(/(\d+)\s*(Month|Months)/);
    if (!durationMatch) return false;
    const months = parseInt(durationMatch[1]);
    const endDate = addMonths(new Date(createdAt), months);
    return now <= endDate;
  }

  private isMedicationDue(now: Date, schedule: string, frequency: string): boolean {
    const currentHour = now.getHours();
    const currentDay = now.getDay(); // 0 (Sunday) to 6 (Saturday)
    const currentDate = now.getDate();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();

    switch (frequency) {
      case 'Daily':
        return this.isScheduleMatch(now, schedule);
      case 'Weekly':
        return this.isScheduleMatch(now, schedule) && currentDay === 0; // Adjust based on your schedule logic
      case 'Monthly':
        return this.isScheduleMatch(now, schedule) && currentDate === 15; // Adjust based on your schedule logic
      case 'As Needed':
        return false; // Default to false unless specified otherwise (user discretion)
      default:
        return false;
    }
  }

  private isScheduleMatch(now: Date, schedule: string): boolean {
    const currentHour = now.getHours();
    switch (schedule) {
      case 'Before Breakfast':
        return currentHour >= 6 && currentHour < 9; // 6 AM to 9 AM
      case 'After Breakfast':
        return currentHour >= 9 && currentHour < 12; // 9 AM to 12 PM
      case 'Before Lunch':
        return currentHour >= 11 && currentHour < 13; // 11 AM to 1 PM
      case 'After Lunch':
        return currentHour >= 13 && currentHour < 15; // 1 PM to 3 PM
      case 'Before Dinner':
        return currentHour >= 17 && currentHour < 19; // 5 PM to 7 PM
      case 'After Dinner':
        return currentHour >= 19 && currentHour < 22; // 7 PM to 10 PM
      case 'Before Meals':
        return currentHour >= 6 && currentHour < 19; // Any meal time (6 AM to 7 PM)
      case 'After Meals':
        return currentHour >= 9 && currentHour < 22; // After any meal (9 AM to 10 PM)
      default:
        return false;
    }
  }

  private isDueToday(now: Date, schedule: string, frequency: string): boolean {
    return this.isMedicationDue(now, schedule, frequency);
  }

  private isDueThisWeek(now: Date, schedule: string, frequency: string): boolean {
    const startOfWeekDate = startOfWeek(now);
    const endOfWeekDate = endOfWeek(now);
    return this.isMedicationDue(now, schedule, frequency) &&
           now >= startOfWeekDate && now <= endOfWeekDate;
  }

  private isDueThisMonth(now: Date, schedule: string, frequency: string): boolean {
    const startOfMonthDate = startOfMonth(now);
    const endOfMonthDate = endOfMonth(now);
    return this.isMedicationDue(now, schedule, frequency) &&
           now >= startOfMonthDate && now <= endOfMonthDate;
  }

  async findOne(id: string): Promise<ExtendedMedicationDocument | null> {
    return this.medicationModel
      .findById(id)
      .lean() // Use lean() for performance
      .exec() as unknown as ExtendedMedicationDocument | null; // Cast to ensure type compatibility
  }

  async remove(id: string): Promise<void> {
    await this.medicationModel.findByIdAndDelete(id).exec();
  }
}
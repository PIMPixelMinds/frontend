import { Module } from '@nestjs/common';
import { MedicationService } from './medication.service';
import { MedicationController } from './medication.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { FileUploadService } from 'src/auth/fileUpload.service';
import { MedicationSchema } from './schema/medication.schema';

@Module({
  imports: [
    // Register the Medication schema with Mongoose
    MongooseModule.forFeature([
      {
        name: 'Medication',
        schema: MedicationSchema,
      },
    ]),
    // Optionally include JwtModule if authentication is required for medication endpoints
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: { expiresIn: '5m' },
      }),
    }),
  ],
  controllers: [MedicationController],
  providers: [MedicationService, FileUploadService], // Add FileUploadService if handling photo uploads
  exports: [MedicationService], // Optional: export the service if other modules need it
})
export class MedicationModule {}
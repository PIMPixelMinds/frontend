import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { NewsModule } from './news/news.module';
import { AppointmentModule } from './appointment/appointment.module';
import { ScheduleModule } from '@nestjs/schedule';
import { ActivityModule } from './activity/activity.module';
import { MedicationModule } from './medication/medication.module';
import { HistoriqueModule } from './historique/historique.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: '.env',
      isGlobal: true,
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const host = configService.get<string>('DB_HOST');
        const port = configService.get<string>('DB_PORT');
        const dbName = configService.get<string>('DB_NAME');
        const user = configService.get<string>('DB_USER');
        const pass = configService.get<string>('DB_PASS');

        const credentials = user && pass ? `${user}:${pass}@` : '';
        const uri = `mongodb://${credentials}${host}:${port}/${dbName}`;

        return { uri };
      },
    }),
    AuthModule,
    NewsModule,
    ScheduleModule.forRoot(),
    AppointmentModule,
    ActivityModule,
    MedicationModule,
    HistoriqueModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

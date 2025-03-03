import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { NewsController } from './news.controller';
import { NewsService } from './news.service';
import { AIService } from './ai.service';
import { News, NewsSchema } from './schema/news.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: News.name, schema: NewsSchema }])],
  controllers: [NewsController],
  providers: [NewsService, AIService],  // ✅ Add AIService
  exports: [NewsService, AIService],    // ✅ Export AIService
})
export class NewsModule {}
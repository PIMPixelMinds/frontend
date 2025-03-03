import { Controller, Get, Query } from '@nestjs/common';
import { NewsService } from './news.service';
import { AIService } from './ai.service';

@Controller('news')
export class NewsController {
  constructor(
    private readonly newsService: NewsService,
    private readonly aiService: AIService
  ) {}

  @Get('latest')
  async getLatestNews() {
    const news = await this.newsService.fetchGoogleNews();
    const articles = news.map(article => article.title);
    const summarizedNews = await this.aiService.summarizeNews(articles);
    return news.map((article, index) => ({
      ...article,
      summary: summarizedNews[index]?.summary || "No summary available",
    }));
  }

  @Get('personalized')
  async getPersonalizedNews(@Query('interest') interest: string) {
    const newsList = await this.newsService.fetchGoogleNews();
    return await this.aiService.rankNews(newsList, interest);
  }
}
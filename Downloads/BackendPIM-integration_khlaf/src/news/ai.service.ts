import axios from 'axios';
import { Injectable } from '@nestjs/common';

@Injectable()
export class AIService {
  private readonly apiKey = 'YOUR_GEMINI_API_KEY';
  private readonly geminiURL = `https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateText?key=${this.apiKey}`;

  async summarizeNews(articles: string[]) {
    const API_KEY = process.env.GEMINI_API_KEY;
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${API_KEY}`;
  
    const prompt = `Summarize these news articles: ${JSON.stringify(articles)}. 
    Return JSON format: [{"title": "News Title", "summary": "Short summary"}]`;
  
    try {
      const response = await axios.post(url, {
        contents: [{ parts: [{ text: prompt }] }],
      });
  
      const summaries = JSON.parse(response.data.candidates?.[0]?.content?.parts?.[0]?.text.trim());
      return summaries;
    } catch (error) {
      console.error("Gemini API Error:", error.response?.data || error.message);
      return { error: "Failed to summarize news." };
    }
  }

  async classifySentiment(articleText: string): Promise<string> {
    const prompt = `Classify this MS news article as positive, neutral, or negative: ${articleText}`;
    const response = await axios.post(this.geminiURL, { prompt });
    return response.data?.candidates?.[0]?.text ?? 'neutral';
  }

  async rankNews(newsList: any[], userInterest: string) {
    const API_KEY = process.env.GEMINI_API_KEY;
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${API_KEY}`;
  
    const prompt = `Rank these MS news articles from most relevant to least relevant based on the user's interest: ${userInterest}. 
    Articles: ${JSON.stringify(newsList)}.
  
    Return ONLY valid JSON in the exact format:
    [{"title": "News Title", "rank": 1}, {"title": "Another News Title", "rank": 2}]
    
    Do NOT include any Markdown formatting, code blocks, explanations, or extra text.`;
  
    try {
      const response = await axios.post(url, {
        contents: [{ parts: [{ text: prompt }] }],
      });
  
      let aiResponse = response.data.candidates?.[0]?.content?.parts?.[0]?.text.trim();
  
      // 🚨 Remove unwanted Markdown code block markers (` ```json ... ``` `)
      if (aiResponse.startsWith("```json")) {
        aiResponse = aiResponse.replace(/```json|```/g, "").trim();
      }
  
      // ✅ Parse clean JSON response
      const rankedNews = JSON.parse(aiResponse);
      return { ranked_news: rankedNews };
    } catch (error) {
      console.error("Error parsing AI response:", error);
      return { error: "Invalid AI response format." };
    }
  }
}

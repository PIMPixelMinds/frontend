import axios from 'axios';
import * as cheerio from 'cheerio';
import { Injectable } from '@nestjs/common';
import { google } from 'googleapis';

@Injectable()
export class NewsService {
  async fetchGoogleNews() {
    const GOOGLE_CSE_ID = process.env.GOOGLE_CSE_ID;
    const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY;
  
    const url = `https://www.googleapis.com/customsearch/v1?q=Multiple+Sclerosis+news&cx=${GOOGLE_CSE_ID}&key=${GOOGLE_API_KEY}`;
  
    console.log("🔹 Google News API Request:", url); // Debugging
  
    try {
      const { data } = await axios.get(url);
      return data.items.map(item => ({
        title: item.title,
        link: item.link,
        image: item.pagemap?.cse_image?.[0]?.src || ""
      }));
    } catch (error) {
      console.error("Google API Error:", error.response?.data || error.message);
      throw new Error("Failed to fetch news.");
    }
  }
}

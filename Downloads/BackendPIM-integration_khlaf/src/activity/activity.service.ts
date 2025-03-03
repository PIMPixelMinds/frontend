import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Activity } from './schema/activity.schema';
import axios from 'axios';
import { Cron } from '@nestjs/schedule';

@Injectable()
export class ActivityService {
  constructor(@InjectModel(Activity.name) private activityModel: Model<Activity>) {}

  private readonly apiKey = 'AIzaSyBZQe1llW9DUioerUA4SE6NzzGbP97t30o'; // Replace with your real API key
  private readonly apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${this.apiKey}`;

  // 🔥 Fetch & Save AI-generated Activities every 3 minutes
  @Cron('*/3 * * * *') // This cron job runs every 3 minutes
  async fetchAndSaveActivities(): Promise<void> {
    console.log("🚀 [fetchAndSaveActivities] - Started");

    try {
      console.log("📡 Sending request to AI API...");
      const response = await axios.post(this.apiUrl, {
        contents: [
          {
            parts: [
              {
                text: "Suggest 4 activities for multiple sclerosis patients. Return JSON array [{\"activity\": \"string\", \"description\": \"string\"}]"
              }
            ]
          }
        ]
      });

      console.log("🌐 [AI Response]:", JSON.stringify(response.data, null, 2));

      // Validate response format
      if (!response.data.candidates || response.data.candidates.length === 0) {
        console.log("❌ [Error] No candidates found in AI response.");
        return;
      }

      // Extract AI response text
      let textResponse = response.data.candidates[0]?.content?.parts[0]?.text?.trim() || "";
      console.log("📌 [Raw AI Output]:", textResponse);

      // Remove code block formatting if present
      if (textResponse.startsWith("```json")) {
        textResponse = textResponse.replace("```json", "").replace("```", "").trim();
      }

      // Parse JSON safely
      const activities = JSON.parse(textResponse);
      console.log("✅ [Parsed Activities]:", activities);

      // Validate received activities
      if (!Array.isArray(activities) || activities.length === 0) {
        console.log("⚠️ [Warning] No valid activities received.");
        return;
      }

      // Store activities in MongoDB (all activities)
      console.log("💾 Saving new activities...");
      const savedActivities = await this.activityModel.insertMany(activities);
      console.log("✅ [Saved Activities]:", savedActivities);
    } catch (error) {
      console.error("❌ [API Call Failed]:", error.response?.data || error.message);
    }
  }

  // 🔥 Get the latest 4 activities for today
  async getActivities(): Promise<Activity[]> {
    console.log("📡 [getActivities] - Fetching latest activities for today...");

    // Get today's date in YYYY-MM-DD format
    const today = new Date().toISOString().split('T')[0];

    // Fetch only activities created today
    const activities = await this.activityModel
      .find({
        createdAt: { $gte: new Date(`${today}T00:00:00Z`) }, // Start of today
      })
      .sort({ createdAt: -1 })  // Sort by createdAt in descending order
      .limit(4)
      .exec();  // Get the latest 4 activities created today

    console.log("✅ [Fetched Activities]:", activities);
    return activities;
  }
}

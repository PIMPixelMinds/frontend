import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { Historique } from './schema/historique.entity';

@Injectable()
export class HistoriqueService {
  constructor(
    @InjectModel(Historique.name) private historiqueModel: Model<Historique>,
    private httpService: HttpService
  ) {}

  // 🔹 Générer une description avec OpenAI
  async generateDescription(userText: string): Promise<string> {
    const apiKey = process.env.OPENAI_API_KEY;
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    const requestBody = {
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: "Tu es un assistant médical qui reformule les descriptions de douleur en une phrase claire et précise avec la premiere personne du singulier." },
        { role: 'user', content: userText },
        { role: 'system', content: `La date et l'heure actuelles sont : ${new Date().toLocaleString()}.` }
      ],
      temperature: 0.5
    };

    const response = await firstValueFrom(
      this.httpService.post(apiUrl, requestBody, {
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json'
        }
      })
    );

    return response.data.choices[0].message.content;
  }

  // 🔹 Enregistrer l'historique
  async saveHistory(userId: string, imageUrl: string, userText: string) {
    const description = await this.generateDescription(userText);

    const newHistorique = new this.historiqueModel({
      user: userId,
      imageUrl,
      generatedDescription: description,
    });

    return newHistorique.save();
  }

  async getHistoryByUserId(userId: string) {
    console.log("🧐 Requête MongoDB avec userId :", userId);
    
    const result = await this.historiqueModel.find({ user: userId }).sort({ createdAt: -1 }).exec();
    
    console.log("📂 Résultat de la requête :", result);
    
    return result;
  }
  
  
  
}

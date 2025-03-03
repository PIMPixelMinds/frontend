import { HistoriqueService } from './historique.service';
import { Controller, Post, UploadedFile, UseInterceptors, Request, Body, UseGuards, Get } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';
import { FileUploadService } from 'src/auth/fileUpload.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';

@Controller('historique')
export class HistoriqueController {
  constructor(private readonly historiqueService: HistoriqueService) {}

  @Post()
  async createHistorique(
    @Body('userId') userId: string,
    @Body('imageUrl') imageUrl: string,
    @Body('userText') userText: string
  ) {
    return this.historiqueService.saveHistory(userId, imageUrl, userText);
  }

@Post('/upload-screenshot')
@UseGuards(JwtAuthGuard)
@UseInterceptors(FileInterceptor('screenshot', FileUploadService.multerOptions))
async uploadScreenshot(@UploadedFile() file: Express.Multer.File, @Request() req) {
    console.log("🔹 Headers reçus :", req.headers);
  console.log("🔹 Utilisateur JWT décodé :", req.user);

  if (!file) {
    console.log("❌ Aucun fichier reçu !");
    return { message: 'Aucun fichier envoyé !' };
  }

  const userId = req.user?.userId; 
  if (!userId) {
    console.log("❌ L'utilisateur n'est pas défini !");
    return { message: "Utilisateur non authentifié !" };
  }
  const fileUrl = `http://localhost:3000/uploads/images/${file.filename}`;
  const userText = req.body.userText || "Aucune description fournie";


  console.log("🔹 Headers reçus :", req.headers);
console.log("🔹 Fichier reçu :", file);
console.log("🔹 Body reçu :", req.body);


  return this.historiqueService.saveHistory(userId, fileUrl, userText);
}


@Get()
@UseGuards(JwtAuthGuard)
async getHistorique(@Request() req) {
  const userId = req.user?.userId;
  console.log("📜 Récupération de l'historique pour l'utilisateur connecté, ID:", userId);

  if (!userId) {
    return { message: "Utilisateur non authentifié !" };
  }

  return this.historiqueService.getHistoryByUserId(userId);
}
  
}

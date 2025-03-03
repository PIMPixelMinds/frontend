import { Injectable } from '@nestjs/common';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class FileUploadService {
  static multerOptions = {
    storage: diskStorage({
      destination: (req, file, callback) => {
        const fileType = file.mimetype.split('/')[0];
        const uploadPath = fileType === 'image' ? './uploads/images' : './uploads/documents';
        callback(null, uploadPath);
      },
      filename: (req, file, callback) => {
        const filename = uuidv4() + extname(file.originalname);
        callback(null, filename);
      }
    }),
    fileFilter: (req, file, callback) => {
      console.log("🔍 Type du fichier reçu :", file.mimetype, "Nom :", file.originalname);
      const allowedMimeTypes = [
        'image/jpeg', 'image/jpg', 'image/png', 'image/gif',
        'application/pdf',
        'text/plain',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document' // DOCX
      ];

      if (!allowedMimeTypes.includes(file.mimetype)) {
        return callback(new Error('Only images (jpeg, jpg, png, gif) and documents (pdf, txt, docx) are allowed!'), false);
      }
      callback(null, true);
    }
  };
}

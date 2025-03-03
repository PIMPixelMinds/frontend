import * as nodemailer from 'nodemailer';
import { Injectable } from '@nestjs/common';

@Injectable()
export class MailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'benmabroukyassine399@gmail.com',
        pass: 'wqby imfs ekpd qrgu',
      },
    });
  }

  async sendPasswordResetEmail(to: string, resetCode: number) {
    const mailOptions = {
      from: 'Signify <benmabroukyassine399@gmail.com>',
      to: to,
      subject: 'Password Reset Request',
      html: `
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>Password Reset</title>
            <style>
              body {
                font-family: 'Arial', sans-serif;
                background-color: #f4f4f4;
                margin: 0;
                padding: 0;
                color: #333;
              }
              .email-container {
                width: 100%;
                max-width: 600px;
                margin: 30px auto;
                background-color: #ffffff;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                padding: 20px;
                text-align: center;
              }
              .email-header {
                background-color: rgba(83, 16, 208, 0.91); /* Changed to the requested color */
                padding: 15px;
                color: #ffffff;
                border-radius: 8px 8px 0 0;
              }
              .email-header h2 {
                margin: 0;
                font-size: 24px;
              }
              .email-body {
                margin: 20px 0;
                font-size: 16px;
                line-height: 1.5;
              }
              .reset-code {
                font-size: 24px;
                font-weight: bold;
                color:rgba(83, 16, 208, 0.91); /* Changed to the requested color */
                background-color: #ffffff; /* Slightly lightened background for contrast */
                padding: 10px;
                border-radius: 5px;
                display: inline-block;
                margin: 20px 0;
              }
              .footer {
                margin-top: 30px;
                font-size: 12px;
                color: #777;
              }
              .footer a {
                color: #c386f8; /* Changed to the requested color */
                text-decoration: none;
              }
            </style>
          </head>
          <body>
            <div class="email-container">
              <div class="email-header">
                <h2>Password Reset Request</h2>
              </div>
              <div class="email-body">
                <p>Dear ${to}</p>
                <p>We received a request to reset your password. To complete the process, please use the following verification code:</p>
                <div class="reset-code">${resetCode}</div>
                <p>This code will expire in 1 Hour. If you did not request a password reset, please ignore this email.</p>
              </div>
              <div class="footer">
                <p>Thank you for using our service!</p>
                <p>Best regards,<br/>Signify Team</p>
              </div>
            </div>
          </body>
        </html>
      `,
    };

    try {
      await this.transporter.sendMail(mailOptions);
      console.log('Password reset email sent successfully');
    } catch (error) {
      console.error('Error sending email:', error);
    }
  }
}
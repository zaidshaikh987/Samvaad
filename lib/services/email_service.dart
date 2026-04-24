// lib/services/email_service.dart
// SMTP email service for OTP delivery

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // SMTP Configuration (Update with your credentials)
  // For production, use environment variables or secure config
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _senderEmail = 'your-email@gmail.com'; // Update this
  static const String _senderPassword = 'your-app-password'; // Update this
  static const String _senderName = 'Samvaad Mental Health';
  
  // Send OTP email
  Future<void> sendOTPEmail(String recipientEmail, String otp) async {
    final smtpServer = gmail(_senderEmail, _senderPassword);
    
    final message = Message()
      ..from = Address(_senderEmail, _senderName)
      ..recipients.add(recipientEmail)
      ..subject = 'Your Samvaad Verification Code'
      ..html = _buildOTPEmailHTML(otp);
    
    try {
      final sendReport = await send(message, smtpServer);
      print('OTP email sent: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('Failed to send OTP email: $e');
      
      // Retry logic
      for (var attempt = 0; attempt < 2; attempt++) {
        await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        try {
          await send(message, smtpServer);
          print('OTP email sent on retry ${attempt + 1}');
          return;
        } catch (retryError) {
          print('Retry ${attempt + 1} failed: $retryError');
        }
      }
      
      throw Exception('Failed to send OTP email after retries');
    }
  }
  
  // Build OTP email HTML template
  String _buildOTPEmailHTML(String otp) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: #f5f7fa;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 40px auto;
      background-color: #ffffff;
      border-radius: 12px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      overflow: hidden;
    }
    .header {
      background: linear-gradient(135deg, #4361EE 0%, #4CC9F0 100%);
      padding: 30px;
      text-align: center;
      color: #ffffff;
    }
    .header h1 {
      margin: 0;
      font-size: 28px;
      font-weight: 600;
    }
    .content {
      padding: 40px 30px;
    }
    .otp-box {
      background-color: #f8f9fa;
      border: 2px dashed #4361EE;
      border-radius: 8px;
      padding: 20px;
      text-align: center;
      margin: 30px 0;
    }
    .otp-code {
      font-size: 36px;
      font-weight: bold;
      color: #4361EE;
      letter-spacing: 8px;
      margin: 10px 0;
    }
    .message {
      color: #495057;
      font-size: 16px;
      line-height: 1.6;
      margin-bottom: 20px;
    }
    .warning {
      background-color: #fff3cd;
      border-left: 4px solid #ffc107;
      padding: 15px;
      margin: 20px 0;
      border-radius: 4px;
    }
    .warning p {
      margin: 0;
      color: #856404;
      font-size: 14px;
    }
    .footer {
      background-color: #f8f9fa;
      padding: 20px 30px;
      text-align: center;
      color: #6c757d;
      font-size: 14px;
    }
    .footer a {
      color: #4361EE;
      text-decoration: none;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🧠 Samvaad</h1>
      <p style="margin: 10px 0 0 0; font-size: 16px;">Mental Health Support</p>
    </div>
    
    <div class="content">
      <p class="message">Hello,</p>
      <p class="message">
        Thank you for choosing Samvaad. To complete your email verification, 
        please use the following One-Time Password (OTP):
      </p>
      
      <div class="otp-box">
        <p style="margin: 0; color: #6c757d; font-size: 14px;">Your Verification Code</p>
        <div class="otp-code">$otp</div>
        <p style="margin: 0; color: #6c757d; font-size: 14px;">Valid for 10 minutes</p>
      </div>
      
      <p class="message">
        Enter this code in the Samvaad app to verify your email address and 
        complete your registration.
      </p>
      
      <div class="warning">
        <p><strong>⚠️ Security Notice:</strong> Never share this code with anyone. 
        Samvaad will never ask for your OTP via phone or email.</p>
      </div>
      
      <p class="message">
        If you didn't request this code, please ignore this email or contact our 
        support team if you have concerns.
      </p>
    </div>
    
    <div class="footer">
      <p>
        Need help? Contact us at 
        <a href="mailto:support@samvaad.app">support@samvaad.app</a>
      </p>
      <p style="margin-top: 10px;">
        © 2024 Samvaad. All rights reserved.
      </p>
    </div>
  </div>
</body>
</html>
    ''';
  }
  
  // Send welcome email
  Future<void> sendWelcomeEmail(String recipientEmail, String userName) async {
    final smtpServer = gmail(_senderEmail, _senderPassword);
    
    final message = Message()
      ..from = Address(_senderEmail, _senderName)
      ..recipients.add(recipientEmail)
      ..subject = 'Welcome to Samvaad! 🎉'
      ..html = _buildWelcomeEmailHTML(userName);
    
    try {
      await send(message, smtpServer);
      print('Welcome email sent successfully');
    } catch (e) {
      print('Failed to send welcome email: $e');
      // Don't throw error for welcome email
    }
  }
  
  String _buildWelcomeEmailHTML(String userName) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; background-color: #f5f7fa; }
    .container { max-width: 600px; margin: 40px auto; background: #fff; border-radius: 12px; padding: 40px; }
    h1 { color: #4361EE; }
    p { color: #495057; line-height: 1.6; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Welcome to Samvaad, $userName! 🎉</h1>
    <p>We're thrilled to have you join our mental health support community.</p>
    <p>Samvaad is here to support your emotional well-being journey with:</p>
    <ul>
      <li>Daily mood tracking and insights</li>
      <li>AI-powered emotional support (Emobot & Chatbot)</li>
      <li>Safe community discussions</li>
      <li>Professional therapist connections</li>
      <li>Private journaling</li>
    </ul>
    <p>Remember: You're not alone. We're here for you, every step of the way. 💙</p>
    <p>Best regards,<br>The Samvaad Team</p>
  </div>
</body>
</html>
    ''';
  }
}

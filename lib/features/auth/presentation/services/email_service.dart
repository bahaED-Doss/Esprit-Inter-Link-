import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Configuration SMTP (Votre mot de passe d'application semble correct)
  static const String _smtpServer = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _username = 'boubakerwessim@gmail.com';
  static const String _password = 'kooh aczo nkme svbm'; // Mot de passe d'application

  // Couleur principale de votre application
  static const String _primaryColor = '#8B1C1C'; // Rouge Esprit

  // Méthode principale pour envoyer des emails
  Future<void> sendPasswordResetEmail({
    required String email,
    required String resetToken,
  }) async {
    try {
      // Lien profond (Deep Link) - Assurez-vous que 'espritinterlink' est configuré dans votre AndroidManifest.xml
      final resetLink = 'espritinterlink://reset-password?token=$resetToken';

      // 🚀 Nouveau Template HTML/CSS professionnel
      final String htmlBody = '''
      <!DOCTYPE html>
      <html lang="fr">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
              body {
                  margin: 0;
                  padding: 0;
                  font-family: 'Poppins', Arial, sans-serif;
                  background-color: #f4f5f6;
              }
              .container {
                  width: 90%;
                  max-width: 600px;
                  margin: 20px auto;
                  background-color: #ffffff;
                  border-radius: 16px;
                  overflow: hidden;
                  box-shadow: 0 4px 15px rgba(0,0,0,0.05);
              }
              .header {
                  background-color: $_primaryColor;
                  padding: 40px 20px;
                  text-align: center;
              }
              .header h1 {
                  color: #ffffff;
                  font-size: 32px;
                  font-weight: 700;
                  margin: 0;
              }
              .content {
                  padding: 40px 40px;
                  color: #333333;
                  line-height: 1.7;
              }
              .content p {
                  font-size: 16px;
                  color: #555555;
              }
              .button-container {
                  text-align: center;
                  padding: 20px 0;
              }
              .button {
                  display: inline-block;
                  padding: 14px 28px;
                  background-color: $_primaryColor;
                  color: #ffffff;
                  font-size: 16px;
                  font-weight: 600;
                  text-decoration: none;
                  border-radius: 12px;
                  transition: background-color 0.3s;
              }
              .link {
                  font-size: 12px;
                  color: #777777;
                  word-break: break-all;
                  padding: 0 20px;
                  text-align: center;
              }
              .footer {
                  background-color: #f9f9f9;
                  padding: 30px;
                  text-align: center;
                  font-size: 12px;
                  color: #999999;
              }
          </style>
          <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
      </head>
      <body>
          <div class="container">
              <div class="header">
                  <h1>Esprit Interlink</h1>
              </div>
              <div class="content">
                  <h2 style="color: #333; font-weight: 600;">Réinitialisation de mot de passe</h2>
                  <p>Bonjour,</p>
                  <p>Nous avons reçu une demande de réinitialisation de votre mot de passe pour votre compte Esprit Interlink. Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet e-mail.</p>
                  <p>Pour choisir un nouveau mot de passe, cliquez sur le bouton ci-dessous :</p>
                  
                  <div class="button-container">
                      <a href="$resetLink" target="_blank" class="button">
                          Réinitialiser mon mot de passe
                      </a>
                  </div>
                  
                  <p>Ce lien de réinitialisation expirera dans <strong>1 heure</strong>.</p>
                  <hr style="border: none; border-top: 1px solid #eeeeee; margin: 30px 0;">
                  <p class="link">Si le bouton ne fonctionne pas, copiez et collez ce lien dans votre navigateur :<br>
                      <a href="$resetLink" style="color: $_primaryColor; text-decoration: none;">$resetLink</a>
                  </p>
              </div>
              <div class="footer">
                  <p>© ${DateTime.now().year} Esprit Interlink. Tous droits réservés.</p>
              </div>
          </div>
      </body>
      </html>
      ''';

      await _sendEmailViaSMTP(
        to: email,
        subject: 'Réinitialisation de votre mot de passe - Esprit Interlink',
        html: htmlBody,
      );

      print('✅ Email de réinitialisation envoyé à: $email');
    } catch (e) {
      print('❌ Erreur envoi email: $e');
      throw Exception('Erreur lors de l\'envoi de l\'email: $e');
    }
  }

  // Méthode privée pour envoyer via SMTP
  Future<void> _sendEmailViaSMTP({
    required String to,
    required String subject,
    required String html,
  }) async {
    try {
      // Configuration du serveur SMTP
      final smtpServer = SmtpServer(
        _smtpServer,
        port: _smtpPort,
        username: _username,
        password: _password,
      );

      // Création du message
      final message = Message()
        ..from = Address(_username, 'Esprit Interlink')
        ..recipients.add(to)
        ..subject = subject
        ..html = html;

      // Envoi de l'email
      final sendReport = await send(message, smtpServer);

      print('📧 Email envoyé avec succès: ${sendReport.toString()}');
    } catch (e) {
      print('❌ Erreur SMTP: $e');
      rethrow;
    }
  }
}
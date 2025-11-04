import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // Configuration SMTP (à mettre dans les variables d'environnement)
  static const String _smtpServer = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _username = 'boubakerwessim@gmail.com';
  static const String _password = 'zvmm iqiy ebzh erkx'; // Utiliser un mot de passe d'application

  // Méthode principale pour envoyer des emails
  Future<void> sendPasswordResetEmail({
    required String email,
    required String resetToken,
  }) async {
    try {
      final resetLink = 'espritinterlink://reset-password?token=$resetToken';

      await _sendEmailViaSMTP(
        to: email,
        subject: 'Réinitialisation de votre mot de passe - Esprit Interlink',
        html: '''
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
              .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
              .header { text-align: center; color: #1976D2; margin-bottom: 20px; }
              .button { display: inline-block; padding: 12px 24px; background: #1976D2; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
              .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>Esprit Interlink</h1>
                <h2>Réinitialisation de mot de passe</h2>
              </div>
              
              <p>Bonjour,</p>
              
              <p>Vous avez demandé la réinitialisation de votre mot de passe. Cliquez sur le bouton ci-dessous pour créer un nouveau mot de passe :</p>
              
              <div style="text-align: center;">
                <a href="$resetLink" class="button">
                  Réinitialiser mon mot de passe
                </a>
              </div>
              
              <p>Si le bouton ne fonctionne pas, copiez et collez ce lien dans votre navigateur :</p>
              <p style="word-break: break-all; color: #1976D2;">$resetLink</p>
              
              <p><strong>Ce lien expirera dans 1 heure.</strong></p>
              
              <p>Si vous n'avez pas demandé cette réinitialisation, veuillez ignorer cet email.</p>
              
              <div class="footer">
                <p>Cordialement,<br>L'équipe Esprit Interlink</p>
                <p>© ${DateTime.now().year} Esprit Interlink. Tous droits réservés.</p>
              </div>
            </div>
          </body>
          </html>
        ''',
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
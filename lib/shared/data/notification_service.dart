import 'package:sqflite/sqflite.dart';
import '../../data/datasources/local/database_helper.dart';

class NotificationService {
  // Ajoute une notification pour un utilisateur
  static Future<void> addNotificationForUser(int userId, String message, {String title = 'Notification', String type = 'SYSTEM', int? referenceId}) async {
    await DatabaseHelper.insertNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      referenceId: referenceId,
    );
  }

  // Récupère le nombre de notifications non lues pour un utilisateur
  static Future<int> getUnreadCount(int userId) async {
    return await DatabaseHelper.getUnreadNotificationCount(userId);
  }

  // Récupère toutes les notifications pour un utilisateur
  static Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId) async {
    return await DatabaseHelper.getNotificationsForUser(userId);
  }

  // Marque toutes les notifications comme lues pour un utilisateur
  static Future<void> markAllAsRead(int userId) async {
    await DatabaseHelper.markAllNotificationsRead(userId);
  }
}

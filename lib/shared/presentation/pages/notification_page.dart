import 'package:flutter/material.dart';
import '../../../data/datasources/local/database_helper.dart' as CoreDB;

class NotificationPage extends StatefulWidget {
  final int userId;
  const NotificationPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final items = await CoreDB.DatabaseHelper.getNotificationsForUser(widget.userId);
    // Marquer comme lues après chargement (best-effort)
    await CoreDB.DatabaseHelper.markAllNotificationsRead(widget.userId);
    return items;
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1C1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() => _future = _load()),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/IllustNotification.png', width: 180, height: 180),
                  const SizedBox(height: 32),
                  const Text(
                    'You have no notifications yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B1C1C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final n = items[index];
              final title = n['title'] as String? ?? 'Notification';
              final msg = n['message'] as String? ?? '';
              final type = n['type'] as String? ?? 'SYSTEM';
              final createdAt = (n['created_at'] as String?) ?? '';
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    type == 'TASK' ? Icons.task : (type == 'PROJECT' ? Icons.folder_open : Icons.notifications),
                    color: const Color(0xFF8B1C1C),
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(msg),
                      const SizedBox(height: 6),
                      Text(_formatDate(createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}

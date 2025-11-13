import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';

class EditAboutMePage extends StatefulWidget {
  final String initialText;

  const EditAboutMePage({super.key, required this.initialText});

  @override
  State<EditAboutMePage> createState() => _EditAboutMePageState();
}

class _EditAboutMePageState extends State<EditAboutMePage> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveAboutMe() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    bool success = false;
    String? error;

    try {
      success = await authProvider.updateGeneralProfile(
        fullName: authProvider.user?.fullName,
        phone: authProvider.user?.phone,
        aboutMe: _controller.text,
      );
      if (!success) {
        error = authProvider.error;
      }
    } catch (e) {
      error = e.toString();
    }

    // 🚀 CORRECTION : Gérer l'état de chargement et la navigation en toute sécurité
    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Erreur de sauvegarde')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('About me'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                maxLines: null,
                minLines: 10,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Tell me about you.',
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAboutMe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
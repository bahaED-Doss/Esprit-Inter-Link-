import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/profile_models.dart';

class EditAppreciationPage extends StatefulWidget {
  final Appreciation? appreciation;

  const EditAppreciationPage({super.key, this.appreciation});

  @override
  State<EditAppreciationPage> createState() => _EditAppreciationPageState();
}

class _EditAppreciationPageState extends State<EditAppreciationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contextController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final app = widget.appreciation;
    if (app != null) {
      _titleController.text = app.title;
      _contextController.text = app.context;
      _yearController.text = app.year;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contextController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  final InputDecoration _inputDecoration = InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  void _saveAppreciation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    try {
      bool success;
      if (widget.appreciation == null) {
        success = await authProvider.addAppreciation(
          title: _titleController.text,
          context: _contextController.text,
          year: _yearController.text,
        );
      } else {
        success = await authProvider.updateAppreciation(
          id: widget.appreciation!.id!,
          title: _titleController.text,
          context: _contextController.text,
          year: _yearController.text,
        );
      }

      if (success) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Erreur de sauvegarde')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // TODO: Implémenter le dialogue de suppression

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appreciation != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: isEditing ? const Icon(Icons.close) : const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Change Appreciation' : 'Add Appreciation'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration.copyWith(hintText: 'Wireless Symposium (RWS)'),
                        validator: (v) => v!.isEmpty ? 'Titre requis' : null,
                      ),
                      const SizedBox(height: 20),

                      const Text('Context', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _contextController,
                        decoration: _inputDecoration.copyWith(hintText: 'Young Scientist'),
                      ),
                      const SizedBox(height: 20),

                      const Text('Year', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration.copyWith(hintText: '2014'),
                        validator: (v) => v!.isEmpty || v.length != 4 ? 'Année requise (AAAA)' : null,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Boutons (similaires à EditWorkExperiencePage)
              const SizedBox(height: 20),
              Row(
                children: [
                  if (isEditing)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () { /* _showDeleteConfirmationDialog */ },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0D0D0),
                          foregroundColor: const Color(0xFF8B1C1C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('REMOVE'),
                      ),
                    ),
                  if (isEditing) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAppreciation,
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
            ],
          ),
        ),
      ),
    );
  }
}
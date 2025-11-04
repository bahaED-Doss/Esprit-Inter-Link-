import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/profile_models.dart';
import 'package:intl/intl.dart';

class EditWorkExperiencePage extends StatefulWidget {
  final WorkExperience? experience;

  const EditWorkExperiencePage({super.key, this.experience});

  @override
  State<EditWorkExperiencePage> createState() => _EditWorkExperiencePageState();
}

class _EditWorkExperiencePageState extends State<EditWorkExperiencePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final exp = widget.experience;
    if (exp != null) {
      _titleController.text = exp.title;
      _companyController.text = exp.company;
      _descriptionController.text = exp.description ?? '';
      _startDate = exp.startDate;
      _endDate = exp.endDate;
      _isCurrent = exp.endDate == null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final InputDecoration _inputDecoration = InputDecoration(
    // ... (Styles de décoration uniformes)
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  Future<void> _selectDate(bool isStart) async {
    final initialDate = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
          _isCurrent = false;
        }
      });
    }
  }

  void _saveExperience() async {
    if (!_formKey.currentState!.validate() || _startDate == null) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    try {
      bool success;
      if (widget.experience == null) {
        success = await authProvider.addWorkExperience(
          title: _titleController.text,
          company: _companyController.text,
          startDate: _startDate!,
          endDate: _isCurrent ? null : _endDate,
          description: _descriptionController.text,
        );
      } else {
        success = await authProvider.updateWorkExperience(
          id: widget.experience!.id!,
          title: _titleController.text,
          company: _companyController.text,
          startDate: _startDate!,
          endDate: _isCurrent ? null : _endDate,
          description: _descriptionController.text,
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

  Future<void> _showDeleteConfirmationDialog() async {
    // Implémentation du dialogue de suppression similaire à EditEducationPage
    // ...
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.experience != null;

    // ... (Structure Scaffold, AppBar, Form, SingleChildScrollView)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: isEditing ? const Icon(Icons.close) : const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Change Work Experience' : 'Add Work Experience'),
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
                      // Job Title
                      const Text('Job title', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration.copyWith(hintText: 'Manager'),
                        validator: (v) => v!.isEmpty ? 'Titre requis' : null,
                      ),
                      const SizedBox(height: 20),

                      // Company
                      const Text('Company', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _companyController,
                        decoration: _inputDecoration.copyWith(hintText: 'Amazon Inc'),
                        validator: (v) => v!.isEmpty ? 'Compagnie requise' : null,
                      ),
                      const SizedBox(height: 20),

                      // Start Date / End Date
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                GestureDetector(
                                  onTap: () => _selectDate(true),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: _inputDecoration.copyWith(
                                        hintText: _startDate != null
                                            ? DateFormat('MMM yyyy').format(_startDate!)
                                            : 'Select date',
                                      ),
                                      validator: (v) => _startDate == null ? 'Date requise' : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                GestureDetector(
                                  onTap: _isCurrent ? null : () => _selectDate(false),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      enabled: !_isCurrent,
                                      decoration: _inputDecoration.copyWith(
                                        hintText: _isCurrent
                                            ? 'Present'
                                            : (_endDate != null ? DateFormat('MMM yyyy').format(_endDate!) : 'Select date'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Checkbox "This is my position now"
                      Row(
                        children: [
                          Checkbox(
                            value: _isCurrent,
                            onChanged: (v) => setState(() {
                              _isCurrent = v ?? false;
                              if (_isCurrent) _endDate = null;
                            }),
                            activeColor: const Color(0xFF8B1C1C),
                          ),
                          const Text('This is my position now'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        minLines: 3,
                        decoration: _inputDecoration.copyWith(
                          hintText: 'Write additional information here',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Boutons
              const SizedBox(height: 20),
              Row(
                children: [
                  if (isEditing)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _showDeleteConfirmationDialog,
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
                      onPressed: _isLoading ? null : _saveExperience,
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
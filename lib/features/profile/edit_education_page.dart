import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/profile_models.dart';
import 'package:intl/intl.dart';
import 'selection_page.dart';

class EditEducationPage extends StatefulWidget {
  final Education? education;

  const EditEducationPage({super.key, this.education});

  @override
  State<EditEducationPage> createState() => _EditEducationPageState();
}

class _EditEducationPageState extends State<EditEducationPage> {
  // ... (tous les contrôleurs et initState/dispose/inputDecoration/selectDate/navigateToSelection)
  final _formKey = GlobalKey<FormState>();
  final _degreeController = TextEditingController();
  final _institutionController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isLoading = false;

  final List<String> _levelOptions = ['Bachelor of Information Technology', 'Bachelor of Science in Computer Science', 'Master of Arts', 'PhD'];
  final List<String> _institutionOptions = ['University of Oxford', 'University of Manchester', 'Esprit University', 'National University of Lesotho'];
  final List<String> _fieldOptions = ['Information Technology', 'Business Information Systems', 'Computer Information Science', 'Data Science', 'History and Information'];

  @override
  void initState() {
    super.initState();
    final edu = widget.education;
    if (edu != null) {
      _degreeController.text = edu.degree;
      _institutionController.text = edu.institution;
      _startDate = edu.startDate;
      _endDate = edu.endDate;
      _isCurrent = edu.endDate == null;
      _fieldOfStudyController.text = edu.fieldOfStudy ?? 'Information Technology';
      _descriptionController.text = edu.description ?? '';
    }
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _institutionController.dispose();
    _fieldOfStudyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final InputDecoration _inputDecoration = InputDecoration(
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

  Future<void> _navigateToSelection({
    required String title,
    required List<String> options,
    required TextEditingController controller,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectionPage(
          title: title,
          options: options,
          initialValue: controller.text,
        ),
      ),
    );
    if (result != null && result is String) {
      controller.text = result;
    }
  }


  // 🚀 CORRECTION DE LA MÉTHODE DE SAUVEGARDE
  void _saveEducation() async {
    if (!_formKey.currentState!.validate() || _startDate == null) {
      // Afficher une erreur si la date de début est manquante
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date de début.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    bool success = false;
    String? error;

    try {
      if (_degreeController.text.isEmpty || _institutionController.text.isEmpty) {
        throw Exception('Veuillez remplir le niveau et l\'institution.');
      }

      if (widget.education == null) {
        success = await authProvider.addEducation(
          degree: _degreeController.text,
          institution: _institutionController.text,
          fieldOfStudy: _fieldOfStudyController.text.isNotEmpty ? _fieldOfStudyController.text : null,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          startDate: _startDate!,
          endDate: _isCurrent ? null : _endDate,
        );
      } else {
        success = await authProvider.updateEducation(
          id: widget.education!.id!,
          degree: _degreeController.text,
          institution: _institutionController.text,
          fieldOfStudy: _fieldOfStudyController.text.isNotEmpty ? _fieldOfStudyController.text : null,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          startDate: _startDate!,
          endDate: _isCurrent ? null : _endDate,
        );
      }
      if (!success) error = authProvider.error;

    } catch (e) {
      error = e.toString();
    }

    // 🚀 GESTION SÉCURISÉE DU CONTEXTE
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

  // ... (_showDeleteConfirmationDialog est correct)
  Future<void> _showDeleteConfirmationDialog() async {
    final authProvider = context.read<AuthProvider>();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_handle, color: Colors.grey, size: 24),
              const SizedBox(height: 16),
              const Text(
                'Remove Education ?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to delete this education entry?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Fermer le dialog
                    setState(() => _isLoading = true);
                    bool success = false;
                    String? error;

                    try {
                      success = await authProvider.deleteEducation(widget.education!.id!);
                      if (!success) error = authProvider.error;
                    } catch (e) {
                      error = e.toString();
                    }

                    if (mounted) {
                      setState(() => _isLoading = false);
                      if (success) {
                        Navigator.pop(context); // Fermer la page d'édition
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error ?? 'Erreur de suppression')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1C1C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('REMOVE EDUCATION', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: const Color(0xFF8B1C1C),
                  ),
                  child: const Text('CANCEL'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final isEditing = widget.education != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: isEditing ? const Icon(Icons.close) : const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Change Education' : 'Add Education'),
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
                      // Level of Education
                      const Text('Level of education', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _degreeController,
                        readOnly: true,
                        decoration: _inputDecoration.copyWith(
                          hintText: isEditing ? 'Bachelor of Information Technology' : 'Select level',
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () => _navigateToSelection(
                          title: 'Level of Education',
                          options: _levelOptions,
                          controller: _degreeController,
                        ),
                        validator: (v) => v!.isEmpty ? 'Le niveau est requis' : null,
                      ),
                      const SizedBox(height: 20),

                      // Institution name
                      const Text('Institution name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _institutionController,
                        readOnly: true,
                        decoration: _inputDecoration.copyWith(
                          hintText: isEditing ? 'University of Oxford' : 'Enter institution name',
                          suffixIcon: const Icon(Icons.search),
                        ),
                        onTap: () => _navigateToSelection(
                          title: 'Institution Name',
                          options: _institutionOptions,
                          controller: _institutionController,
                        ),
                        validator: (v) => v!.isEmpty ? 'L\'institution est requise' : null,
                      ),
                      const SizedBox(height: 20),

                      // Field of study
                      const Text('Field of study', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(
                        controller: _fieldOfStudyController,
                        readOnly: true,
                        decoration: _inputDecoration.copyWith(
                          hintText: 'Information Technology',
                          suffixIcon: const Icon(Icons.search),
                        ),
                        onTap: () => _navigateToSelection(
                          title: 'Field of Study',
                          options: _fieldOptions,
                          controller: _fieldOfStudyController,
                        ),
                      ),
                      const SizedBox(height: 20),

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
                      onPressed: _isLoading ? null : _saveEducation,
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../aplication/models/internship_model.dart';
import '../../../aplication/providers/application_provider.dart';

/// Page de formulaire pour créer ou modifier une offre de stage
class HRInternshipFormPage extends StatefulWidget {
  final int hrId;
  final Internship? internship; // null = create, non-null = edit

  const HRInternshipFormPage({
    Key? key,
    required this.hrId,
    this.internship,
  }) : super(key: key);

  @override
  State<HRInternshipFormPage> createState() => _HRInternshipFormPageState();
}

class _HRInternshipFormPageState extends State<HRInternshipFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  
  InternshipType _selectedType = InternshipType.SUMMER;
  InternshipStatus _selectedStatus = InternshipStatus.OPEN;
  DateTime? _startDate;
  
  final List<TextEditingController> _requirementControllers = [];
  final List<TextEditingController> _skillControllers = [];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.internship != null) {
      // Edit mode - populate fields
      _titleController.text = widget.internship!.title;
      _descriptionController.text = widget.internship!.description;
      _companyController.text = widget.internship!.companyName;
      _locationController.text = widget.internship!.location;
      _durationController.text = widget.internship!.duration.toString();
      _selectedType = widget.internship!.type;
      _selectedStatus = widget.internship!.status;
      _startDate = widget.internship!.startDate;
      
      // Load requirements
      for (var req in widget.internship!.requirements) {
        final controller = TextEditingController(text: req);
        _requirementControllers.add(controller);
      }
      
      // Load skills
      for (var skill in widget.internship!.skills) {
        final controller = TextEditingController(text: skill);
        _skillControllers.add(controller);
      }
    } else {
      // Create mode - add empty fields
      _addRequirement();
      _addSkill();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    for (var controller in _requirementControllers) {
      controller.dispose();
    }
    for (var controller in _skillControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addRequirement() {
    setState(() {
      _requirementControllers.add(TextEditingController());
    });
  }

  void _removeRequirement(int index) {
    setState(() {
      _requirementControllers[index].dispose();
      _requirementControllers.removeAt(index);
    });
  }

  void _addSkill() {
    setState(() {
      _skillControllers.add(TextEditingController());
    });
  }

  void _removeSkill(int index) {
    setState(() {
      _skillControllers[index].dispose();
      _skillControllers.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B1C1C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Collect requirements and skills
    final requirements = _requirementControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    
    final skills = _skillControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final internship = Internship(
      id: widget.internship?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      companyName: _companyController.text.trim(),
      location: _locationController.text.trim(),
      type: _selectedType,
      status: _selectedStatus,
      duration: int.parse(_durationController.text.trim()),
      requirements: requirements,
      skills: skills,
      startDate: _startDate!,
      hrId: widget.hrId,
    );

    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    
    bool success;
    if (widget.internship == null) {
      // Create
      await provider.addInternship(internship);
      success = provider.internshipError == null;
    } else {
      // Update
      await provider.updateInternship(internship);
      success = provider.internshipError == null;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.internship == null
                ? 'Internship created successfully!'
                : 'Internship updated successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.internshipError ?? 'Failed to save internship'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.internship != null;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1C1C),
        title: Text(
          isEdit ? 'Edit Internship' : 'Create Internship',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildTextField(
                controller: _titleController,
                label: 'Title *',
                hint: 'e.g., Web Developer Intern',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Company Name
              _buildTextField(
                controller: _companyController,
                label: 'Company Name *',
                hint: 'e.g., TechCorp',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Location
              _buildTextField(
                controller: _locationController,
                label: 'Location *',
                hint: 'e.g., Tunis',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description *',
                hint: 'Describe the internship opportunity...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Type and Duration
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Type *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<InternshipType>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          items: InternshipType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_getTypeDisplay(type)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _durationController,
                      label: 'Duration (months) *',
                      hint: '3',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Status and Start Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<InternshipStatus>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          items: InternshipStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(_getStatusDisplay(status)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: 'Start Date *',
                      date: _startDate,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Requirements
              _buildListSection(
                title: 'Requirements',
                controllers: _requirementControllers,
                onAdd: _addRequirement,
                onRemove: _removeRequirement,
                hint: 'e.g., Basic knowledge of HTML/CSS',
              ),
              
              const SizedBox(height: 24),
              
              // Skills
              _buildListSection(
                title: 'Skills',
                controllers: _skillControllers,
                onAdd: _addSkill,
                onRemove: _removeSkill,
                hint: 'e.g., JavaScript, React',
              ),
              
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1C1C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEdit ? 'UPDATE' : 'CREATE',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B1C1C), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Select',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? Colors.black87 : Colors.grey[400],
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection({
    required String title,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B1C1C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => onRemove(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getTypeDisplay(InternshipType type) {
    switch (type) {
      case InternshipType.PFE:
        return 'PFE';
      case InternshipType.SUMMER:
        return 'Summer Internship';
      case InternshipType.INITIATION:
        return 'Initiation';
    }
  }

  String _getStatusDisplay(InternshipStatus status) {
    switch (status) {
      case InternshipStatus.OPEN:
        return 'Open';
      case InternshipStatus.CLOSED:
        return 'Closed';
      case InternshipStatus.IN_PROGRESS:
        return 'In Progress';
    }
  }
}

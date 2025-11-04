import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';

class CreatePMPage extends StatefulWidget {
  const CreatePMPage({super.key});

  @override
  State<CreatePMPage> createState() => _CreatePMPageState();
}

class _CreatePMPageState extends State<CreatePMPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isLoading = false;

  final InputDecoration _inputDecoration = InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  Future<void> _createPM() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.createProjectManager(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        jobTitle: _jobTitleController.text,
        department: _departmentController.text,
        city: _cityController.text,
        country: _countryController.text,
      );

      if (success) {
        // Afficher un succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project Manager account created successfully!')),
        );
        Navigator.pop(context);
      } else {
        throw Exception(authProvider.error ?? 'Creation failed.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create PM Account'),
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
                      const Text('Account Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextFormField(controller: _emailController, decoration: _inputDecoration.copyWith(hintText: 'Email'), validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email requis' : null),
                      const SizedBox(height: 10),
                      TextFormField(controller: _passwordController, obscureText: true, decoration: _inputDecoration.copyWith(hintText: 'Temporary Password'), validator: (v) => v!.length < 6 ? 'Min 6 chars' : null),
                      const SizedBox(height: 20),

                      const Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextFormField(controller: _fullNameController, decoration: _inputDecoration.copyWith(hintText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Nom requis' : null),
                      const SizedBox(height: 10),
                      TextFormField(controller: _phoneController, decoration: _inputDecoration.copyWith(hintText: 'Phone'), keyboardType: TextInputType.phone),
                      const SizedBox(height: 20),

                      const Text('Role Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      TextFormField(controller: _jobTitleController, decoration: _inputDecoration.copyWith(hintText: 'Job Title (Ex: Senior PM)')),
                      const SizedBox(height: 10),
                      TextFormField(controller: _departmentController, decoration: _inputDecoration.copyWith(hintText: 'Department (Ex: IT)'), validator: (v) => v!.isEmpty ? 'Département requis' : null),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _cityController, decoration: _inputDecoration.copyWith(hintText: 'City'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextFormField(controller: _countryController, decoration: _inputDecoration.copyWith(hintText: 'Country'))),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPM,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1C1C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CREATE PROJECT MANAGER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:esprit_interlink/features/auth/presentation/models/user_model.dart';

class AdminUserFormPage extends StatefulWidget {
  final User? userToEdit;
  const AdminUserFormPage({super.key, this.userToEdit});

  @override
  State<AdminUserFormPage> createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends State<AdminUserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;

  bool get _isEditMode => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final user = widget.userToEdit!;
      _emailController.text = user.email;
      _fullNameController.text = user.fullName ?? '';
      _phoneController.text = user.phone ?? '';
      _selectedRole = user.role.toLowerCase();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  final InputDecoration _inputDecoration = InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF9F9F9),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // 🚀 CORRECTION DE LA MÉTHODE DE SAUVEGARDE (Navigation sécurisée)
  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    bool success = false;
    String? errorMsg;

    try {
      if (_isEditMode) {
        // Mode Mise à jour
        final updatedUser = widget.userToEdit!.copyWith(
          email: _emailController.text,
          fullName: _fullNameController.text,
          phone: _phoneController.text,
          role: _selectedRole,
        );
        success = await authProvider.adminUpdateUser(updatedUser);
      } else {
        // Mode Création
        success = await authProvider.adminCreateUser(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
          fullName: _fullNameController.text,
          phone: _phoneController.text,
        );
      }
      if (!success) errorMsg = authProvider.error;
    } catch (e) {
      errorMsg = e.toString();
    }

    // 🚀 CORRECTION : Gérer la navigation après la sauvegarde
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'User Updated Successfully!' : 'User Created Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Revenir en arrière en renvoyant 'true' pour indiquer le succès
      Navigator.pop(context, true);
    } else {
      // Si la sauvegarde échoue, on reste sur la page et on affiche l'erreur
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? 'Erreur de sauvegarde'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit User' : 'Add New User'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
                      const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _fullNameController, decoration: _inputDecoration, validator: (v) => v!.isEmpty ? 'Name is required' : null),
                      const SizedBox(height: 20),

                      const Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _emailController, decoration: _inputDecoration, validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email is required' : null),
                      const SizedBox(height: 20),

                      // Afficher le champ mot de passe uniquement en mode Création
                      if (!_isEditMode) ...[
                        const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        TextFormField(controller: _passwordController, obscureText: true, decoration: _inputDecoration, validator: (v) => v!.length < 6 ? 'Min 6 chars' : null),
                        const SizedBox(height: 20),
                      ],

                      const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      TextFormField(controller: _phoneController, decoration: _inputDecoration, keyboardType: TextInputType.phone),
                      const SizedBox(height: 20),

                      const Text('Role', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(border: InputBorder.none),
                          items: ['student', 'hr', 'pm', 'admin'].map((role) {
                            return DropdownMenuItem(value: role, child: Text(role.toUpperCase()));
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedRole = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1C1C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isEditMode ? 'UPDATE USER' : 'CREATE USER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
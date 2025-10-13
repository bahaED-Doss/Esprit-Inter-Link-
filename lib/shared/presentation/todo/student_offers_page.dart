import 'package:flutter/material.dart';
class StudentOffersPage extends StatelessWidget {
  const StudentOffersPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Offres')), body: const Center(child: Text('Offres pour étudiant')));
  }
}


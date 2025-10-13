import 'package:flutter/material.dart';
class PMTasksPage extends StatelessWidget {
  const PMTasksPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Tâches')), body: const Center(child: Text('Tâches PM')));
  }
}


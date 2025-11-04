import 'package:flutter/material.dart';

class SavedCandidatesPage extends StatelessWidget {
  final List<String> savedCandidates;
  const SavedCandidatesPage({super.key, this.savedCandidates = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Candidates', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF821E23),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: savedCandidates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/noSaving.png', width: 120),
                  const SizedBox(height: 24),
                  const Text(
                    "No Savings",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      "You don't have any candidates saved, please find it in the candidates section to save them",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 180,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: null, // Bouton inactif
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1C1C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('FIND CANDIDATES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: savedCandidates.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(savedCandidates[index]),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';

class SavedOffersPage extends StatelessWidget {
  final List<String> savedOffers;
  const SavedOffersPage({Key? key, this.savedOffers = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Offers', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF821E23),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: savedOffers.isEmpty
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
                      "You don't have any offres saved, please find it in search to save offres",
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
                      child: const Text('FIND OFFERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: savedOffers.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text(savedOffers[index]),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';

class SelectionPage extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? initialValue;

  const SelectionPage({
    super.key,
    required this.title,
    required this.options,
    this.initialValue,
  });

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _searchController.addListener(_filterOptions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterOptions);
    _searchController.dispose();
    super.dispose();
  }

  void _filterOptions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Champ de recherche (similaire au design)
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search or type...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _filterOptions();
                  },
                )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Liste des options filtrées
            Expanded(
              child: ListView.builder(
                itemCount: _filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = _filteredOptions[index];
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      // Retourne l'option sélectionnée à la page précédente
                      Navigator.pop(context, option);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
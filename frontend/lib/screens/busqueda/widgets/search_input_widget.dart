import 'package:flutter/material.dart';

class SearchInputWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchInputWidget({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar doctor por nombre',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}

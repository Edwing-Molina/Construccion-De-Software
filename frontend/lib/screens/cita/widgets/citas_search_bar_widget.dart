import 'package:flutter/material.dart';

class CitasSearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const CitasSearchBarWidget({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar por paciente, fecha o estado',
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}

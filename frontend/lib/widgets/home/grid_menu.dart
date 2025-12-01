import 'package:flutter/material.dart';
import 'menu_card.dart';

class GridMenu extends StatelessWidget {
  final String userRole;
  final Function(String) onNavigate;

  const GridMenu({super.key, required this.userRole, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double minCardWidth = 150.0;
        const double spacing = 20.0;

        int crossAxisCount =
            ((constraints.maxWidth + spacing) / (minCardWidth + spacing))
                .floor();
        crossAxisCount = crossAxisCount.clamp(1, 5);

        if (constraints.maxWidth < 400) {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.4,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return MenuCard(
              icon: item['icon'],
              title: item['title'],
              subtitle: item['subtitle'],
              onTap: () => onNavigate(item['route']),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMenuItems() {
    final List<Map<String, dynamic>> items = [];

    items.add({
      'icon': Icons.calendar_today,
      'title': 'Mis Citas',
      'subtitle': 'Ver y gestionar citas',
      'route': '/citas',
    });

    if (userRole.toLowerCase() == 'patient' ||
        userRole.toLowerCase() == 'paciente') {
      items.add({
        'icon': Icons.search,
        'title': 'Buscar Doctores',
        'subtitle': 'Encuentra especialistas y agenda tu cita',
        'route': '/busqueda',
      });

      items.add({
        'icon': Icons.medical_services,
        'title': 'Historial Médico',
        'subtitle': 'Consulta tu historial clínico',
        'route': '/historial-medico',
      });
    }

    if (userRole.toLowerCase() == 'doctor' ||
        userRole.toLowerCase() == 'medico') {
      items.add({
        'icon': Icons.schedule,
        'title': 'Patrones de Trabajo',
        'subtitle': 'Configurar horarios y disponibilidad',
        'route': '/patrones-trabajo',
      });
    }

    // Tarjeta de perfil (todos los roles)
    items.add({
      'icon': Icons.person,
      'title': 'Mi Perfil',
      'subtitle': 'Información personal',
      'route': '/perfil',
    });

    return items;
  }
}

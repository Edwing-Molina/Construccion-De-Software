import 'package:flutter/material.dart';
import 'package:frontend/models/doctor.dart';
import 'package:frontend/models/specialty.dart';
import 'package:frontend/screens/busqueda/agendar_screen.dart';
import 'package:frontend/services/busqueda/busqueda_service.dart';
import 'package:frontend/services/service_locator.dart';
import 'package:frontend/widgets/common/loading_indicator.dart';
import 'package:go_router/go_router.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final SpecialtyService _specialtyService = SpecialtyService();
  final BusquedaService _busquedaService = BusquedaService();

  List<Specialty> _specialties = [];
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  int? _selectedSpecialtyId;
  bool _loading = false;
  String? _error;
  String _searchText = '';
  String? userRole;
  String? userName;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadInitialData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = serviceLocator.authService;
      final user = await authService.getCurrentUser();
      final role = await authService.getUserRole();

      setState(() {
        userName = user?.name;
        userRole = role;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final specialties = await _specialtyService.fetchSpecialties();
      final doctors = await _busquedaService.fetchDoctors();

      setState(() {
        _specialties = specialties;
        _allDoctors = doctors;
        _filteredDoctors = doctors;
      });
    } catch (e) {
      setState(() => _error = 'Error al cargar datos: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors =
          _allDoctors.where((doctor) {
            final matchSpecialty =
                _selectedSpecialtyId == null ||
                doctor.specialties?.any((s) => s.id == _selectedSpecialtyId) ==
                    true;
            final matchSearch =
                _searchText.isEmpty ||
                (doctor.user?.name ?? '').toLowerCase().contains(
                  _searchText.toLowerCase(),
                );
            return matchSpecialty && matchSearch;
          }).toList();
    });
  }

  void _onSpecialtyChanged(int? value) {
    _selectedSpecialtyId = value;
    _filterDoctors();
  }

  void _onSearchChanged(String value) {
    _searchText = value;
    _filterDoctors();
  }

  void _showAvailability(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AgendarScreen(doctorId: doctor.id!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userRole != 'patient' && userRole != 'doctor') {
      return Scaffold(body: Center(child: Text('Acceso denegado :(')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Doctores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home'); // Vuelve a la pantalla anterior
          },
        ),
      ),
      body:
          _loading
              ? const LoadingIndicator(message: 'Cargando datos...')
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : Column(
                children: [
                  _buildSearchInput(),
                  _buildSpecialtyDropdown(),
                  const Divider(height: 1),
                  Expanded(child: _buildDoctorList()),
                ],
              ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar doctor por nombre',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildSpecialtyDropdown() {
    // Construimos una lista que incluye null para "Todas las especialidades"
    final specialtiesWithAll = [null, ..._specialties];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: DropdownMenu<int?>(
        width: MediaQuery.of(context).size.width,
        // Valor seleccionado
        initialSelection: _selectedSpecialtyId,
        // Hint cuando no hay selección
        hintText: 'Especialidad',
        // Items con búsqueda interna
        dropdownMenuEntries:
            specialtiesWithAll.map((s) {
              if (s == null) {
                return DropdownMenuEntry<int?>(
                  value: null,
                  label: 'Todas las especialidades',
                );
              } else {
                return DropdownMenuEntry<int?>(value: s.id, label: s.name);
              }
            }).toList(),
        onSelected: (value) {
          _onSpecialtyChanged(value);
        },
      ),
    );
  }

  Widget _buildDoctorList() {
    if (_filteredDoctors.isEmpty) {
      return const Center(child: Text('No hay doctores disponibles.'));
    }

    return ListView.builder(
      itemCount: _filteredDoctors.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        final name = doctor.user?.name ?? 'Sin nombre';
        final specialties =
            doctor.specialties?.map((s) => s.name).join(', ') ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialties,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAvailability(doctor),
                  child: const Text('Ver disponibilidad'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

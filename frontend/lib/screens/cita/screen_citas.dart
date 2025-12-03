import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/logo_section.dart';

/// Screen that shows appointments for the current user.
///
/// Suppports filtering, cancelling and completing appointments.
class ScreenCitas extends StatefulWidget {
  const ScreenCitas({super.key});

  @override
  State<ScreenCitas> createState() => _ScreenCitasState();
}

class _ScreenCitasState extends State<ScreenCitas> {
  bool _isLoading = false;
  List<Appointment> _citas = [];
  List<Appointment> _citasFiltradas = [];
  String? _userRole;
  String _searchTerm = '';

  late final CitasService _citasService;
  late final AuthService _authService;

  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _citasService = serviceLocator.serviceCitas;
    _authService = serviceLocator.authService;
    _loadCitas();
  }

  Future<void> _loadCitas() async {
    setState(() => _isLoading = true);

    try {
      final role = await _authService.getUserRole();
      final citas = await _citasService.listarCitas(role ?? '');

      setState(() {
        _citas = citas;
        _citasFiltradas = List<Appointment>.from(citas);
        _userRole = role;
      });
    } catch (error) {
      _showSnackBar('Error loading appointments: $error', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filtrarCitas(String search) {
    final term = search.trim().toLowerCase();
    setState(() {
      _searchTerm = term;
      _citasFiltradas = _citas.where((cita) {
        if (cita.status.toLowerCase() == 'completado') return false;

        final nombre = cita.patient?.user?.name?.toLowerCase() ?? '';
        final fechaStr = (cita.appointmentDate ?? cita.availableSchedule?.date)
                ?.toLocal();
        final fecha = fechaStr == null
            ? ''
            : _displayDateFormat.format(fechaStr).toLowerCase();
        final estado = cita.status.toLowerCase();

        return nombre.contains(term) ||
            fecha.contains(term) ||
            estado.contains(term);
      }).toList();
    });
  }

  Future<void> _confirmarCancelarCita(int appointmentId) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cancelación'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar esta cita? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await _cancelarCita(appointmentId);
    }
  }

  Future<void> _cancelarCita(int appointmentId) async {
    setState(() => _isLoading = true);
    try {
      await _citasService.cancelarCita(appointmentId);
      await _loadCitas();
      _showSnackBar('Cita cancelada correctamente', color: Colors.red);
    } catch (error) {
      _showSnackBar('Error canceling appointment: $error', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completarCita(int appointmentId) async {
    setState(() => _isLoading = true);
    try {
      await _citasService.completarCita(appointmentId);
      await _loadCitas();
      _showSnackBar('Cita completada correctamente', color: Colors.green);
    } catch (error) {
      _showSnackBar('Error completing appointment: $error', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {Color color = Colors.black}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 10),
              const LogoSection(),
              _buildSearchBar(),
              const SizedBox(height: 10),
              Expanded(child: _buildCitasList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      color: AppColors.uadyBlue,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => context.go('/home'),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Mis Citas',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
        onChanged: _filtrarCitas,
      ),
    );
  }

  Widget _buildCitasList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.uadyBlue),
      );
    }

    final citasVisibles = _citasFiltradas
        .where((c) => c.status != 'completado' && c.status != 'cancelada')
        .toList();

    if (citasVisibles.isEmpty) {
      return const Center(
        child: Text(
          'No tienes citas por el momento',
          style: TextStyle(color: AppColors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: citasVisibles.length,
      itemBuilder: (context, index) {
        final cita = citasVisibles[index];
        return _buildCitaCard(cita);
      },
    );
  }

  Widget _buildCitaCard(Appointment cita) {
    final pacienteNombre = cita.patient?.user?.name ?? 'Paciente';
    final fechaDate =
        (cita.appointmentDate ?? cita.availableSchedule?.date)?.toLocal();
    final startTime = cita.availableSchedule?.startTime;
    final horaFormatted =
        startTime != null ? startTime.format(context) : 'N/D';
    final status = cita.status;
    final doctorId = cita.doctor?.id;
    final clinicId = cita.availableSchedule?.clinicId;
    final formattedDate =
        fechaDate != null ? _displayDateFormat.format(fechaDate) : 'N/D';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userRole == 'doctor')
              Text(
                'Paciente: $pacienteNombre',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (_userRole == 'patient')
              Text(
                'Doctor $doctorId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 6),
            Text('Fecha: $formattedDate - $horaFormatted'),
            const SizedBox(height: 6),
            Text(
              'Estado: $status',
              style: TextStyle(
                color: status == 'completado'
                    ? Colors.green
                    : (status == 'cancelada' ? Colors.red : Colors.orange),
              ),
            ),
            if (_userRole == 'patient' &&
                status != 'completado' &&
                status != 'cancelada')
              CustomButton(
                text: 'Cancelar cita',
                onPressed:
                    _isLoading ? null : () => _confirmarCancelarCita(cita.id!),
                isLoading: _isLoading,
              ),
            const SizedBox(height: 8),
            if (_userRole == 'doctor' &&
                status != 'completado' &&
                status != 'cancelada')
              CustomButton(
                text: 'Completar Cita',
                onPressed: _isLoading ? null : () => _completarCita(cita.id!),
                isLoading: _isLoading,
              ),
            if (_userRole == 'doctor' && status == 'cancelada')
              CustomButton(
                text: 'Quitar cita de la lista',
                onPressed: _isLoading ? null : () => _completarCita(cita.id!),
                isLoading: _isLoading,
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('Más información'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Detalles de la Cita'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (clinicId != null) Text('Clínica Uady:$clinicId'),
                        Text('Hora inicio: $horaFormatted'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

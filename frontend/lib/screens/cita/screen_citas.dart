import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/logo_section.dart';
import 'widgets/cita_card_widget.dart';
import 'widgets/citas_app_bar_widget.dart';
import 'widgets/citas_search_bar_widget.dart';

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

  late final ServiceCitas _citasService;
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
      _citasFiltradas =
          _citas.where((cita) {
            if (cita.status?.toLowerCase() == 'completado') return false;

            final nombre = (cita.patient?.user?.name ?? '').toLowerCase();
            final fechaStr =
                (cita.appointmentDate ?? cita.availableSchedule?.date)
                    ?.toLocal();
            final fecha =
                fechaStr == null
                    ? ''
                    : _displayDateFormat.format(fechaStr).toLowerCase();
            final estado = cita.status?.toLowerCase() ?? '';

            return nombre.contains(term) ||
                fecha.contains(term) ||
                estado.contains(term);
          }).toList();
    });
  }

  Future<void> _confirmarCancelarCita(int appointmentId) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final citasVisibles =
        _citasFiltradas
            .where((c) => c.status != 'completado' && c.status != 'cancelada')
            .toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const CitasAppBarWidget(),
              const SizedBox(height: 10),
              const LogoSection(),
              CitasSearchBarWidget(onSearchChanged: _filtrarCitas),
              const SizedBox(height: 10),
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.uadyBlue,
                          ),
                        )
                        : citasVisibles.isEmpty
                        ? const Center(
                          child: Text(
                            'No tienes citas por el momento',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: citasVisibles.length,
                          itemBuilder: (context, index) {
                            final cita = citasVisibles[index];
                            return CitaCardWidget(
                              cita: cita,
                              userRole: _userRole,
                              isLoading: _isLoading,
                              onCancelPressed:
                                  () => _confirmarCancelarCita(cita.id!),
                              onCompletePressed: () => _completarCita(cita.id!),
                              onRemovePressed: () => _completarCita(cita.id!),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

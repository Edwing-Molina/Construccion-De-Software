import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:frontend/models/doctor_work_pattern.dart';
import 'package:frontend/models/enum_days.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/patron/work_pattern_service.dart';
import 'widgets/index.dart';

class WorkPatternScreen extends StatefulWidget {
  const WorkPatternScreen({super.key});

  @override
  State<WorkPatternScreen> createState() => _WorkPatternScreenState();
}

class _WorkPatternScreenState extends State<WorkPatternScreen> {
  // Theme colors.
  static const Color _azulUady = Color(0xFF002E5F);
  static const Color _doradoUady = Color(0xFFC79316);

  final _formKey = GlobalKey<FormState>();
  late final WorkPatternService _workPatternService = WorkPatternService(
    AuthService(),
  );

  // Form state.
  String? _selectedDay;
  static const List<String> _diasSemana = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _startDate;
  int? _durationDays;
  int _slotDurationMinutes = 30;
  bool _isActive = true;
  bool _isLoading = false;
  bool _showInactive = true;

  final List<DoctorWorkPattern> _workPatterns = [];
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _fetchWorkPatterns();
  }

  Future<void> _fetchWorkPatterns() async {
    setState(() => _isLoading = true);
    try {
      final resp = await _workPatternService.listarPatrones();
      if (resp.success && resp.data != null) {
        setState(() {
          _workPatterns
            ..clear()
            ..addAll(resp.data!);
        });
      } else {
        _showSnackBar(resp.message);
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createWorkPattern() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      _showSnackBar('Selecciona hora inicio y fin');
      return;
    }
    if (_startDate == null) {
      _showSnackBar('Selecciona fecha de inicio');
      return;
    }
    if (_durationDays == null || _durationDays! < 1) {
      _showSnackBar('Ingresa una duración válida');
      return;
    }

    final endDateEffective = _startDate!.add(
      Duration(days: _durationDays! - 1),
    );

    final nuevoPatron = DoctorWorkPattern(
      doctorId: 0, // Se asigna en backend
      clinicId: _workPatterns.isNotEmpty ? _workPatterns.first.clinicId : 1,
      dayOfWeek: _dayStringToEnum(_selectedDay!),
      startTimePattern: _startTime!,
      endTimePattern: _endTime!,
      slotDurationMinutes: _slotDurationMinutes,
      isActive: _isActive,
      startDateEffective: _startDate!,
      endDateEffective: endDateEffective,
    );

    setState(() => _isLoading = true);
    try {
      final resp = await _workPatternService.crearPatron(nuevoPatron);
      if (!resp.success) {
        _showSnackBar(resp.message);
      } else {
        _showSnackBar('Patron creado correctamente');
        final genResp = await _workPatternService.generarHorarios(
          nuevoPatron.startDateEffective,
          nuevoPatron.endDateEffective ?? nuevoPatron.startDateEffective,
        );
        if (!genResp.success) {
          _showSnackBar('Error al generar horarios: ${genResp.message}');
        } else {
          _showSnackBar('Horarios generados correctamente.');
        }
        await _fetchWorkPatterns();
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deactivatePattern(int id) async {
    setState(() => _isLoading = true);
    try {
      final resp = await _workPatternService.desactivarPatron(id);
      if (resp.success) {
        _showSnackBar('Patrón desactivado');
        await _fetchWorkPatterns();
      } else {
        _showSnackBar(resp.message);
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DayOfWeek _dayStringToEnum(String day) {
    switch (day) {
      case 'Monday':
        return DayOfWeek.monday;
      case 'Tuesday':
        return DayOfWeek.tuesday;
      case 'Wednesday':
        return DayOfWeek.wednesday;
      case 'Thursday':
        return DayOfWeek.thursday;
      case 'Friday':
        return DayOfWeek.friday;
      case 'Saturday':
        return DayOfWeek.saturday;
      case 'Sunday':
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _azulUady),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime = TimeOfDay.now();
    final result = await showTimePicker(
      context: context,
      initialTime:
          isStart ? (_startTime ?? initialTime) : (_endTime ?? initialTime),
      builder: (context, child) => _pickerTheme(child),
    );
    if (result == null) return;
    setState(() {
      if (isStart) {
        _startTime = result;
      } else {
        _endTime = result;
      }
    });
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => _pickerTheme(child),
    );
    if (result != null) setState(() => _startDate = result);
  }

  Theme _pickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _azulUady,
          primary: _azulUady,
          secondary: _doradoUady,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      child: child!,
    );
  }

  String _formatTimeOfDay(TimeOfDay? tod) {
    if (tod == null) return 'No seleccionado';
    final h = tod.hour.toString().padLeft(2, '0');
    final m = tod.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime? date) =>
      date == null ? 'No seleccionado' : _dateFormatter.format(date);

  @override
  Widget build(BuildContext context) {
    final displayedPatterns =
        _showInactive
            ? _workPatterns
            : _workPatterns.where((p) => p.isActive).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _azulUady,
        title: const Text(
          'Patrones de Trabajo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    WorkPatternFormWidget(
                      formKey: _formKey,
                      selectedDay: _selectedDay,
                      diasSemana: _diasSemana,
                      startTime: _startTime,
                      endTime: _endTime,
                      startDate: _startDate,
                      slotDurationMinutes: _slotDurationMinutes,
                      isActive: _isActive,
                      isLoading: _isLoading,
                      primaryColor: _azulUady,
                      accentColor: _doradoUady,
                      onPickStartTime: () => _pickTime(isStart: true),
                      onPickEndTime: () => _pickTime(isStart: false),
                      onPickStartDate: _pickStartDate,
                      onDayChanged: (v) => setState(() => _selectedDay = v),
                      onSlotDurationChanged: (v) {
                        if (v != null) setState(() => _slotDurationMinutes = v);
                      },
                      onIsActiveChanged: (v) => setState(() => _isActive = v),
                      onDurationDaysChanged:
                          (v) => setState(() => _durationDays = v),
                      onCreatePattern: _createWorkPattern,
                      formatTimeOfDay: _formatTimeOfDay,
                      formatDate: _formatDate,
                      inputDecoration: _inputDecoration,
                      buttonStyle: _buttonStyle(),
                    ),
                    const SizedBox(height: 24),
                    if (_workPatterns.isNotEmpty)
                      ToggleInactiveButtonWidget(
                        showInactive: _showInactive,
                        onPressed:
                            () =>
                                setState(() => _showInactive = !_showInactive),
                        buttonStyle: _buttonStyle(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (displayedPatterns.isEmpty)
                      const Text('No hay patrones de trabajo.')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedPatterns.length,
                        itemBuilder: (context, index) {
                          final pattern = displayedPatterns[index];
                          return PatternCardWidget(
                            pattern: pattern,
                            primaryColor: _azulUady,
                            accentColor: _doradoUady,
                            onDeactivate: () => _deactivatePattern(pattern.id!),
                            formatTimeOfDay: _formatTimeOfDay,
                            formatDate: _formatDate,
                          );
                        },
                      ),
                  ],
                ),
              ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  ButtonStyle _buttonStyle({EdgeInsetsGeometry? padding}) {
    return ElevatedButton.styleFrom(
      backgroundColor: _doradoUady,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
    );
  }
}

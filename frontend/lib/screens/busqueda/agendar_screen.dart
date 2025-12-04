import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/available_schedule.dart';
import 'package:frontend/screens/busqueda/agendar_widgets/date_selector_widget.dart';
import 'package:frontend/screens/busqueda/agendar_widgets/month_year_selector_widget.dart';
import 'package:frontend/services/busqueda/agendar_service.dart';
import 'package:frontend/widgets/common/loading_indicator.dart';
import 'package:intl/date_symbol_data_local.dart';

class AgendarScreen extends StatefulWidget {
  final int doctorId;

  const AgendarScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<AgendarScreen> createState() => _AgendarScreenState();
}

class _AgendarScreenState extends State<AgendarScreen> {
  final AgendarService _agendarService = AgendarService();
  List<AvailableSchedule> _availableSchedules = [];
  bool _loading = false;
  String? _error;

  // Mes y año seleccionado para filtrar días
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Día seleccionado para mostrar horarios
  DateTime? _selectedDay;

  // Para controlar qué bloque de días mostrar en el selector de días
  int _dayStartIndex = 0;
  final int _visibleDaysCount = 3;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null).then((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final schedules = await _agendarService.fetchAvailableSchedules(
        doctorId: widget.doctorId,
      );

      setState(() {
        _availableSchedules = schedules.where((s) => s.available).toList();

        // Establecer _selectedDay al primer día disponible del mes seleccionado
        final availableDaysThisMonth =
            _availableSchedules
                .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
                .where(
                  (d) =>
                      d.year == _selectedMonth.year &&
                      d.month == _selectedMonth.month,
                )
                .toSet()
                .toList()
              ..sort();

        if (availableDaysThisMonth.isNotEmpty) {
          _selectedDay =
              _selectedDay != null &&
                      availableDaysThisMonth.any(
                        (d) =>
                            d.year == _selectedDay!.year &&
                            d.month == _selectedDay!.month &&
                            d.day == _selectedDay!.day,
                      )
                  ? _selectedDay
                  : availableDaysThisMonth.first;
          _dayStartIndex = 0; // iniciar bloque días en 0 cuando se carga datos
        } else {
          _selectedDay = null;
          _dayStartIndex = 0;
        }
      });
    } catch (e) {
      setState(() => _error = 'Error al cargar datos: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _bookAppointment(int availableScheduleId) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _agendarService.createAppointment(availableScheduleId);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita agendada exitosamente')),
      );
    } catch (e) {
      setState(() => _error = 'Error al agendar cita: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _adjustSelectedDay() {
    final availableDaysThisMonth =
        _availableSchedules
            .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
            .where(
              (d) =>
                  d.year == _selectedMonth.year &&
                  d.month == _selectedMonth.month,
            )
            .toSet()
            .toList()
          ..sort();

    if (availableDaysThisMonth.isNotEmpty) {
      if (_selectedDay == null ||
          !availableDaysThisMonth.any(
            (d) =>
                d.year == _selectedDay!.year &&
                d.month == _selectedDay!.month &&
                d.day == _selectedDay!.day,
          )) {
        _selectedDay = availableDaysThisMonth.first;
      }
      _dayStartIndex = 0;
    } else {
      _selectedDay = null;
      _dayStartIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final horariosDelDia =
        _availableSchedules
            .where(
              (s) =>
                  _selectedDay != null &&
                  s.date.year == _selectedDay!.year &&
                  s.date.month == _selectedDay!.month &&
                  s.date.day == _selectedDay!.day,
            )
            .toList();

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: .95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          if (_loading) {
            return const Center(
              child: LoadingIndicator(message: 'Cargando datos...'),
            );
          }
          if (_error != null) {
            return Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            );
          }

          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Horarios Disponibles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              MonthYearSelectorWidget(
                selectedMonth: _selectedMonth,
                onPreviousMonth: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                    _adjustSelectedDay();
                  });
                },
                onNextMonth: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                    _adjustSelectedDay();
                  });
                },
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final uniqueDays =
                      _availableSchedules
                          .map(
                            (s) =>
                                DateTime(s.date.year, s.date.month, s.date.day),
                          )
                          .where(
                            (d) =>
                                d.year == _selectedMonth.year &&
                                d.month == _selectedMonth.month,
                          )
                          .toSet()
                          .toList();

                  uniqueDays.sort();

                  return DateSelectorWidget(
                    uniqueDays: uniqueDays,
                    selectedDay: _selectedDay,
                    dayStartIndex: _dayStartIndex,
                    visibleDaysCount: _visibleDaysCount,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDay = date;
                      });
                    },
                    onPreviousDays: () {
                      setState(() {
                        _dayStartIndex = (_dayStartIndex - _visibleDaysCount)
                            .clamp(0, uniqueDays.length - 1);
                      });
                    },
                    onNextDays: () {
                      setState(() {
                        _dayStartIndex = (_dayStartIndex + _visibleDaysCount)
                            .clamp(0, uniqueDays.length - 1);
                      });
                    },
                    canGoToPrevious: _dayStartIndex > 0,
                    canGoToNext:
                        _dayStartIndex + _visibleDaysCount < uniqueDays.length,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (horariosDelDia.isEmpty)
                const Text('No hay horarios disponibles.')
              else
                ...horariosDelDia.map(
                  (schedule) => Card(
                    child: ListTile(
                      title: Text(
                        '${schedule.date.toLocal().toIso8601String().split("T")[0]} '
                        '${schedule.startTime.format(context)} - ${schedule.endTime.format(context)}',
                      ),
                      subtitle: Text(
                        schedule.clinic?.id.toString() ?? 'Clínica Uady',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          try {
                            await _bookAppointment(
                              schedule.id!,
                            ); // hace el POST
                            if (context.mounted) {
                              context.go('/citas'); // redirige si todo fue bien
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al agendar: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Agendar'),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

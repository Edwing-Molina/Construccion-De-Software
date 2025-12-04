import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/available_schedule.dart';
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
    print(
      '[AgendasScreen] _bookAppointment llamado con ID: $availableScheduleId',
    );

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('[AgendasScreen] Llamando a createAppointment...');
      await _agendarService.createAppointment(availableScheduleId);
      print('[AgendasScreen] Cita creada, recargando datos...');
      await _loadData();
      print('[AgendasScreen] Datos recargados');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita agendada exitosamente')),
      );
    } catch (e) {
      print('[AgendasScreen] ERROR: $e');
      setState(() => _error = 'Error al agendar cita: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildMonthYearSelector() {
    final monthYearFormat = DateFormat.yMMMM('es');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
              _adjustSelectedDay();
            });
          },
        ),
        Text(
          monthYearFormat.format(_selectedMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month + 1,
              );
              _adjustSelectedDay();
            });
          },
        ),
      ],
    );
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

  Widget _buildDateSelector() {
    if (_selectedDay == null) {
      return const Text('No hay días disponibles en este mes');
    }

    final uniqueDays =
        _availableSchedules
            .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
            .where(
              (d) =>
                  d.year == _selectedMonth.year &&
                  d.month == _selectedMonth.month,
            )
            .toSet()
            .toList();

    uniqueDays.sort();

    // Obtener bloque visible de días según _dayStartIndex y _visibleDaysCount
    final visibleDays =
        uniqueDays.skip(_dayStartIndex).take(_visibleDaysCount).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              _dayStartIndex > 0
                  ? () {
                    setState(() {
                      _dayStartIndex = (_dayStartIndex - _visibleDaysCount)
                          .clamp(0, uniqueDays.length - 1);
                    });
                  }
                  : null,
        ),
        ...visibleDays.map((date) {
          final isSelected =
              _selectedDay != null &&
              _selectedDay!.year == date.year &&
              _selectedDay!.month == date.month &&
              _selectedDay!.day == date.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = date;
              });
            },
            child: Container(
              width: 60,
              height: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E('es').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              _dayStartIndex + _visibleDaysCount < uniqueDays.length
                  ? () {
                    setState(() {
                      _dayStartIndex = (_dayStartIndex + _visibleDaysCount)
                          .clamp(0, uniqueDays.length - 1);
                    });
                  }
                  : null,
        ),
      ],
    );
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

    print('[AgendasScreen] Build: _selectedDay=$_selectedDay');
    print(
      '[AgendasScreen] Build: _availableSchedules count=${_availableSchedules.length}',
    );
    print(
      '[AgendasScreen] Build: horariosDelDia count=${horariosDelDia.length}',
    );

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
              _buildMonthYearSelector(),
              const SizedBox(height: 8),
              _buildDateSelector(),
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

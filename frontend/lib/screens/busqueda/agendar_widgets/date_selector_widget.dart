import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorWidget extends StatelessWidget {
  final List<DateTime> uniqueDays;
  final DateTime? selectedDay;
  final int dayStartIndex;
  final int visibleDaysCount;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousDays;
  final VoidCallback onNextDays;
  final bool canGoToPrevious;
  final bool canGoToNext;

  const DateSelectorWidget({
    super.key,
    required this.uniqueDays,
    required this.selectedDay,
    required this.dayStartIndex,
    required this.visibleDaysCount,
    required this.onDateSelected,
    required this.onPreviousDays,
    required this.onNextDays,
    required this.canGoToPrevious,
    required this.canGoToNext,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDay == null) {
      return const Text('No hay días disponibles en este mes');
    }

    final visibleDays =
        uniqueDays.skip(dayStartIndex).take(visibleDaysCount).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: canGoToPrevious ? onPreviousDays : null,
        ),
        ...visibleDays.map((date) {
          final isSelected =
              selectedDay != null &&
              selectedDay!.year == date.year &&
              selectedDay!.month == date.month &&
              selectedDay!.day == date.day;

          return GestureDetector(
            onTap: () {
              onDateSelected(date);
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
          onPressed: canGoToNext ? onNextDays : null,
        ),
      ],
    );
  }
}

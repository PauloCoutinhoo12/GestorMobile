import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoDiaEquipe extends StatelessWidget {
  final List<String> equipe;
  final List<bool> equipePresente;
  final Function(int, bool) onChanged;

  const InfoDiaEquipe({
    super.key,
    required this.equipe,
    required this.equipePresente,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF90CAF9)),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF90CAF9),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            const Text(
              "Equipe Presente:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: List.generate(equipe.length, (index) =>
                  FilterChip(
                    label: Text(
                      equipe[index],
                      style: TextStyle(
                        color: equipePresente[index]
                            ? Colors.black
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    selected: equipePresente[index],
                    onSelected: (selected) => onChanged(index, selected),
                    backgroundColor: equipePresente[index]
                        ? const Color(0xFF00E676).withOpacity(0.7)
                        : const Color(0xFF1E1E1E),
                    selectedColor: const Color(0xFF00E676),
                    checkmarkColor: Colors.black,
                    side: BorderSide(
                      color: Colors.grey.shade700,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
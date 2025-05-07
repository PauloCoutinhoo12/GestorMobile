import 'package:flutter/material.dart';

class TurnoCard extends StatelessWidget {
  final String turno;
  final TextEditingController bandejasController;
  final TextEditingController gorduraController;
  final bool frituraRealizada;
  final Function(String) onBandejasChanged;
  final Function(String) onGorduraChanged;
  final Function(bool?) onFrituraChanged;

  const TurnoCard({
    super.key,
    required this.turno,
    required this.bandejasController,
    required this.gorduraController,
    required this.frituraRealizada,
    required this.onBandejasChanged,
    required this.onGorduraChanged,
    required this.onFrituraChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Turno da $turno",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bandejasController,
              decoration: const InputDecoration(
                labelText: "Bandejas Produzidas",
                border: OutlineInputBorder(),
                suffixText: "un",
              ),
              keyboardType: TextInputType.number,
              onChanged: onBandejasChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gorduraController,
              decoration: const InputDecoration(
                labelText: "Gordura Usada",
                border: OutlineInputBorder(),
                suffixText: "kg",
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: onGorduraChanged,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: frituraRealizada,
                  onChanged: onFrituraChanged,
                ),
                const Text("Fritura realizada"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
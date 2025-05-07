import 'package:flutter/material.dart';

class TotaisSection extends StatelessWidget {
  final int totalBandejas;
  final double totalGordura;

  const TotaisSection({
    super.key,
    required this.totalBandejas,
    required this.totalGordura,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Card(
          color: const Color(0xFF1E1E1E),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                    "TOTAL DO DIA",
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                            "Bandejas",
                            style: TextStyle(color: Colors.grey)
                        ),
                        Text(
                          "$totalBandejas",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                            "Gordura",
                            style: TextStyle(color: Colors.grey)
                        ),
                        Text(
                          "${totalGordura.toStringAsFixed(1)} kg",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
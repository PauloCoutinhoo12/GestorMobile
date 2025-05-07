import 'package:flutter/material.dart';

class MateriaisSection extends StatelessWidget {
  final double trigoKg;
  final double salKg;
  final double oleoL;
  final double vinagreL;
  final double gorduraKg;
  final int bandejasB2;
  final int sacos;
  final int etiquetas;

  const MateriaisSection({
    super.key,
    required this.trigoKg,
    required this.salKg,
    required this.oleoL,
    required this.vinagreL,
    required this.gorduraKg,
    required this.bandejasB2,
    required this.sacos,
    required this.etiquetas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
            "Materiais Utilizados:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 10),
        DataTable(
          columns: const [
            DataColumn(label: Text("Material")),
            DataColumn(label: Text("Quantidade")),
          ],
          rows: [
            _buildDataRow("Trigo", "${trigoKg.toStringAsFixed(1)} kg"),
            _buildDataRow("Sal", "${salKg.toStringAsFixed(3)} kg"),
            _buildDataRow("Óleo", "${oleoL.toStringAsFixed(3)} L"),
            _buildDataRow("Vinagre", "${vinagreL.toStringAsFixed(3)} L"),
            _buildDataRow("Gordura", "${gorduraKg.toStringAsFixed(1)} kg"),
            _buildDataRow("Bandejas B2", "$bandejasB2 un"),
            _buildDataRow("Sacos", "$sacos un"),
            _buildDataRow("Etiquetas", "$etiquetas un"),
          ],
        ),
      ],
    );
  }

  DataRow _buildDataRow(String label, String value) {
    return DataRow(
      cells: [
        DataCell(Text(label)),
        DataCell(Text(value)),
      ],
    );
  }
}
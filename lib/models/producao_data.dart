import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ProducaoData {
  @HiveField(0)
  final String dia;

  @HiveField(1)
  final int manha;

  @HiveField(2)
  final int tarde;

  @HiveField(3)
  final List<String> equipePresente;

  ProducaoData(
      this.dia,
      this.manha,
      this.tarde,
      [this.equipePresente = const []]
      );
}
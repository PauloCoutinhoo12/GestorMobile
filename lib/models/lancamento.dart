import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Lancamento {
  @HiveField(0)
  final String descricao;

  @HiveField(1)
  final double valor;

  @HiveField(2)
  final String data;

  Lancamento({
    required this.descricao,
    required this.valor,
    required this.data,
  });
}
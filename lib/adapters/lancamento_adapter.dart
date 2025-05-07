import 'package:hive/hive.dart';
import '../models/lancamento.dart';

class LancamentoAdapter extends TypeAdapter<Lancamento> {
  @override
  final int typeId = 1;

  @override
  Lancamento read(BinaryReader reader) {
    return Lancamento(
      descricao: reader.readString(),
      valor: reader.readDouble(),
      data: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Lancamento lancamento) {
    writer.writeString(lancamento.descricao);
    writer.writeDouble(lancamento.valor);
    writer.writeString(lancamento.data);
  }
}
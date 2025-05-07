import 'package:hive/hive.dart';
import '../models/producao_data.dart';

class ProducaoDataAdapter extends TypeAdapter<ProducaoData> {
  @override
  final int typeId = 0;

  @override
  ProducaoData read(BinaryReader reader) {
    return ProducaoData(
      reader.readString(),
      reader.readInt(),
      reader.readInt(),
      List<String>.from(reader.readList()),
    );
  }

  @override
  void write(BinaryWriter writer, ProducaoData producaoData) {
    writer.writeString(producaoData.dia);
    writer.writeInt(producaoData.manha);
    writer.writeInt(producaoData.tarde);
    writer.writeList(producaoData.equipePresente);
  }
}
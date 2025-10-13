import 'package:hive/hive.dart';

/// Hive-backed record for a single monster parameter row.
class MonsterParameter {
  MonsterParameter({required this.label, required this.value});

  String label;
  double value;
}

class MonsterParameterAdapter extends TypeAdapter<MonsterParameter> {
  @override
  final int typeId = 0;

  @override
  MonsterParameter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final label = fields[0] as String? ?? '';
    final value = (fields[1] as num?)?.toDouble() ?? 0;
    return MonsterParameter(label: label, value: value);
  }

  @override
  void write(BinaryWriter writer, MonsterParameter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..writeString(obj.label)
      ..writeByte(1)
      ..writeDouble(obj.value);
  }
}

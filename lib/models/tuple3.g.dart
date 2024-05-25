import 'package:hive/hive.dart';
import 'package:tuple/tuple.dart';

class Tuple3Adapter extends TypeAdapter<Tuple3<int, int, int>> {
  @override
  final int typeId = 5; // Unique adapter type id

  @override
  Tuple3<int, int, int> read(BinaryReader reader) {
    final first = reader.readInt();
    final second = reader.readInt();
    final third = reader.readInt();
    return Tuple3<int, int, int>(first, second, third);
  }

  @override
  void write(BinaryWriter writer, Tuple3<int, int, int> obj) {
    writer.writeInt(obj.item1);
    writer.writeInt(obj.item2);
    writer.writeInt(obj.item3);
  }
}

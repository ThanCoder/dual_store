import 'dart:io';

import 'package:dual_store/src/interfaces/i_writer.dart';
import 'package:dual_store/src/interfaces/types.dart';

class FileRecordWriter extends BaseRecordWriter {
  final File file;
  const FileRecordWriter({
    required this.file,
    required super.id,
    super.parentId = -1,
    super.adapterId = -1,
    super.flag = RecordFlag.active,
    super.queryType = .none,
    super.dataType = .file,
  });

  @override
  Stream<List<int>> writeChunks() {
    return file.openRead();
  }

  @override
  int? get totalDataSize => file.lengthSync();
}

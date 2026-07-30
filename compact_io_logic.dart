// import 'dart:io';

// import 'package:dual_store/src/core/engine/du_header_io.dart';
// import 'package:dual_store/src/core/engine/i_engine_logic.dart';
// import 'package:dual_store/src/core/models/du_header.dart';
// import 'package:dual_store/src/core/models/meta.dart';

// mixin CompactIoLogic on IEngineLogic {
//   set readRaf(RandomAccessFile raf);
//   set writeRaf(RandomAccessFile raf);

//   /// ### Compact
//   void compact(
//     DuHeader header,
//     Map<int, Meta> allMeta, {
//     bool savedBackup = true,
//   }) {
//     final compactFile = File('${writeRaf.path}.tem');
//     final mainFile = File(writeRaf.path);
//     if (compactFile.existsSync()) {
//       compactFile.deleteSync();
//     }
//     final compactRaf = compactFile.openSync(mode: FileMode.write);
//     // write header
//     DuHeaderIo.writeHeader(header, compactRaf);

//     for (var meta in allMeta.values) {
//       readRaf.setPositionSync(meta.headerOffset);

//       _copyBytes(readRaf, compactRaf, meta.totalSize);
//     }

//     // close
//     compactRaf.flushSync();
//     compactRaf.closeSync();

//     if (savedBackup) {
//       mainFile.renameSync('${mainFile.path}.bk');
//     } else {
//       // del main file
//       mainFile.deleteSync();
//     }
//     // rename tem to main db
//     compactFile.renameSync(mainFile.path);

//     // re assign
//     writeRaf = mainFile.openSync(mode: FileMode.append);
//     readRaf = mainFile.openSync(mode: FileMode.read);
//   }
// }

// void _copyBytes(RandomAccessFile src, RandomAccessFile dst, int size) {
//   const chunkSize = 1024 * 1024; // 1MB

//   var remaining = size;

//   while (remaining > 0) {
//     final readSize = remaining > chunkSize ? chunkSize : remaining;

//     final bytes = src.readSync(readSize);

//     if (bytes.isEmpty) {
//       throw Exception('Unexpected EOF');
//     }

//     dst.writeFromSync(bytes);

//     remaining -= bytes.length;
//   }
// }

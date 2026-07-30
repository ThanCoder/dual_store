// import 'dart:typed_data';

// import 'package:dual_store/dual_store.dart';
// import 'package:dual_store/src/core/engine/i_engine_logic.dart';

// /// [ all bytes(24)
// ///
// ///### Fixed Header
// /// flag(1),recordType(1),id(8),parentId(8),adapterTypeId(1),
// /// mataType(1),metaSize(4)
// /// dataType(1),dataSize(8),
// ///
// /// ### N Bytes
// ///
// /// metaData(n bytes),
// /// data(n bytes)
// /// ]
// mixin MetaWriterLogic on IEngineLogic {
//   /// ### Delete Mark
//   bool deleteMarkMeta(Meta meta) {
//     final lastPos = writeRaf.positionSync();
//     // go meta pos
//     writeRaf.setPositionSync(meta.headerOffset);
//     writeRaf.writeByteSync(DuFlag.deleted.value);

//     writeRaf.setPositionSync(lastPos);
//     return true;
//   }

//   Future<Meta> writeMeta(DuMetaRecord rec) async {
//     assert(rec.metaData.length == rec.metaSize);

//     final headerOffset = writeRaf.lengthSync();

//     final data = ByteData(duMetaHeaderLength);
//     int offset = 0;

//     data.setUint8(offset, DuFlag.active.value);
//     offset += 1;
//     data.setUint8(offset, RecordType.meta.value);
//     offset += 1;
//     data.setUint64(offset, rec.id, Endian.little);
//     offset += 8;
//     data.setUint64(offset, rec.parentId, Endian.little);
//     offset += 8;
//     data.setInt8(offset, rec.adapterTypeId);
//     offset += 1;
//     data.setInt8(offset, rec.metaType.value);
//     offset += 1;
//     data.setUint32(offset, rec.metaSize, Endian.little);
//     offset += 4;

//     writeRaf.writeFromSync(data.buffer.asUint8List());
//     writeRaf.writeFromSync(rec.metaData);

//     return Meta(
//       flag: DuFlag.active,
//       id: rec.id,
//       parentId: rec.parentId,
//       adapterTypeId: rec.adapterTypeId,
//       metaType: rec.metaType,
//       metaSize: rec.metaSize,
//       metaData: rec.metaData,
//       headerOffset: headerOffset,
//       totalSize: duMetaHeaderLength + rec.metaSize,
//     );
//   }
// }

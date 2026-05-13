import 'dart:typed_data';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/interfaces/dual_model.dart';

abstract class DualAdapter<T extends DualModel> {
  /// **⚠️ IMPORTANT: FIELD ORDER CONSISTENCY**
  ///
  /// The order in which you write data in [toSmallData] MUST be identical to
  /// the order you read data in [fromSmallData].
  ///
  /// This is a binary-based storage engine. If the sequence of fields is
  /// changed, it will lead to corrupted data or application crashes.
  ///
  /// **Guidelines for Schema Updates:**
  /// - To add new fields, always append them to the END of the sequence.
  /// - NEVER insert a new field in the middle of existing fields.
  /// - NEVER change the data type of an existing field.
  /// ```dart
  /// @override
  ///   Uint8List toSmallData(
  ///     User value,
  ///     int generatedAutoId,
  ///     SmallDataEncoder encoder,
  ///   ) {
  ///     encoder.writeInt(generatedAutoId);  //Position -> 1 //write auto id
  ///     encoder.writeString(value.name); //Position -> 2
  ///     encoder.writeInt(value.age); //Position -> 3
  ///
  ///     return encoder.finishedBytes;
  ///   }
  /// ```
  /// ### Important Field Position
  ///
  Uint8List toSmallData(T value, int generatedAutoId, SmallDataEncoder encoder);

  /// **⚠️ Important Field Position**
  ///```dart
  /// @override
  ///   User fromSmallData(SmallDataDecoder decoder) {
  ///     return User(
  ///       id: decoder.readInt(), //Position -> 1 //generated auto id
  ///       name: decoder.readString(),//Position -> 2
  ///       age: decoder.readInt(),//Position -> 3
  ///     );
  ///   }
  /// ```
  ///
  T fromSmallData(SmallDataDecoder decoder);

  /// Register Adapter Type Id
  ///
  /// The unique identifier for this adapter.
  ///
  /// **IMPORTANT:** Each adapter must have a unique ID (e.g., 1, 2, 3...).
  ///
  /// This ID is stored in the record header to determine which adapter
  ///
  /// should be used to decode the data during retrieval.
  int get adapterTypeId;

  /// Parent Id
  int getParentId(T value) => -1;

  /// id for adapter
  int getId(T value);

  /// Defines how the [BigData] section should be interpreted.
  ///
  /// Choose [BigDataType.file] for very large data (GBs) to ensure
  ///
  /// memory safety through streaming.
  BigDataType get bigDataType => BigDataType.none;
}

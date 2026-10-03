// ignore_for_file: public_member_api_docs

import 'package:dual_store/src/core/models/meta.dart';

abstract class DuEvent {
  const DuEvent();
}

abstract class BoxEvent extends DuEvent {
  final int adapterId;
  const BoxEvent({required this.adapterId});
}

abstract class CompactEvent extends DuEvent {
  const CompactEvent();
}

//********Box************* */
class BoxAdded extends BoxEvent {
  final int id;
  const new({required this.id, required super.adapterId});
}

class BoxUpdated extends BoxEvent {
  final int id;
  const new({required this.id, required super.adapterId});
}

class BoxDeleted extends BoxEvent {
  final int id;
  const new({required this.id, required super.adapterId});
}

class BoxError extends BoxEvent {
  final int id;
  final String message;
  const new({
    required this.id,
    required super.adapterId,
    required this.message,
  });
}

class BoxReadMetaError extends BoxEvent {
  final int id;
  final String message;
  const new({
    required this.id,
    required super.adapterId,
    required this.message,
  });
}

//********Compact************* */
class CompactSuccess extends CompactEvent {
  const CompactSuccess();
}

class CompactError extends CompactEvent {
  final String message;
  const CompactError(this.message);
}

class RecordWrited extends DuEvent {
  final Meta meta;
  const RecordWrited(this.meta);
}

class Open extends DuEvent {}

class Close extends DuEvent {}

class Reload extends DuEvent {}

class ChangePath extends DuEvent {}

class HeaderWrited extends DuEvent {}

/// Synchronously flushes the contents of the file to disk.
class FlushToDisk extends DuEvent {}

class UpdateId extends DuEvent {
  final int id;
  const UpdateId(this.id);
}

class AddId extends DuEvent {
  final int id;
  const AddId(this.id);
}

class DeleteId extends DuEvent {
  final int id;
  const DeleteId(this.id);
}

class DuError extends DuEvent {
  final String message;
  const DuError(this.message);
}

class WriteRecordError extends DuEvent {
  final String message;
  const WriteRecordError(this.message);
}

class RemoveMetaError extends DuEvent {
  final String message;
  const RemoveMetaError(this.message);
}

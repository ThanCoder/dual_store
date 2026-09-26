import 'package:dual_store/src/core/models/meta.dart';

abstract class DuEvent {
  const DuEvent();
}

class RecordWrited extends DuEvent {
  final Meta meta;
  const RecordWrited(this.meta);
}

class CompactSuccess extends DuEvent {
  const CompactSuccess();
}

class CompactError extends DuEvent {
  final String message;
  const CompactError(this.message);
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

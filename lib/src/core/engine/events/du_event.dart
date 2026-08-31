import 'package:dual_store/src/core/models/meta.dart';

abstract class DuEvent {
  const DuEvent();
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

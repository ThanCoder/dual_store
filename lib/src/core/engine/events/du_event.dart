// ignore_for_file: public_member_api_docs

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/models/meta.dart';

abstract class DuEvent {
  const DuEvent();
}

//********Box************* */
abstract class BoxEvent extends DuEvent {
  final int id;
  final int adapterId;
  const new({required this.id, required this.adapterId});
}

class BoxAdded<T extends IDuModel> extends BoxEvent {
  final T value;
  new(this.value, {required super.id, required super.adapterId});
}

class BoxUpdated<T extends IDuModel> extends BoxEvent {
  final T value;
  new(this.value, {required super.id, required super.adapterId});
}

class BoxDeleted<T> extends BoxEvent {
  new({required super.id, required super.adapterId});
}

class BoxError extends BoxEvent {
  final String message;
  const new({
    required super.id,
    required super.adapterId,
    required this.message,
  });
}

class BoxReadMetaError extends BoxEvent {
  final String message;
  const new({
    required super.id,
    required super.adapterId,
    required this.message,
  });
}

//********Image Box************* */
abstract class ImageBoxEvent extends DuEvent {
  final int id;
  const new(this.id);
}

class ImageBoxAdded extends ImageBoxEvent {
  new(super.id);
}

class ImageBoxUpdated extends ImageBoxEvent {
  new(super.id);
}

class ImageBoxDeleted extends ImageBoxEvent {
  new(super.id);
}

class ImageBoxError extends ImageBoxEvent {
  final String message;
  const new(super.id, this.message);
}

//********Compact************* */
abstract class CompactEvent extends DuEvent {
  const CompactEvent();
}

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

//********Error Events************* */
abstract class ErrortEvent extends DuEvent {
  final String message;
  const ErrortEvent(this.message);
}

class DuError extends ErrortEvent {
  const new(super.message);
}

class WriteRecordError extends ErrortEvent {
  const new(super.message);
}

class RemoveMetaError extends ErrortEvent {
  const new(super.message);
}

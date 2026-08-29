// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../dual_store_base.dart';

sealed class DuEvent {
  const DuEvent();
}

class Open extends DuEvent {}

class Close extends DuEvent {}

class Reload extends DuEvent {}

class StateChanged extends DuEvent {}

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

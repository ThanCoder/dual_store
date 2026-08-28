part of '../dual_store_base.dart';

abstract class IDuModel {
  IDuModel();
  late Meta _meta;

  int get generatedId => _meta.id;
}

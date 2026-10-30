import 'package:dual_store/src/core/models/du_header.dart';

///config
class DuStoreConfig {
  /// store header
  final DuHeader header;

  /// const
  const DuStoreConfig({required this.header});

  ///default config
  factory DuStoreConfig.defaultConfig() {
    return .new(header: const DuHeader(magic: 'dust'));
  }
}

import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/reader/i_content_reader.dart';
import 'package:dual_store/src/result_t.dart';

mixin ContentReaderLogic on IEngineLogic {
  Result<R, String> readContentExactSync<R>(IContentReader<R> reader) {
    try {
      readRaf.setPositionSync(reader.meta.contentStartOffset);
      return Ok(reader.readSync(readRaf));
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<Result<R, String>> readContentExact<R>(
    IContentReader<R> reader,
  ) async {
    try {
      readRaf.setPositionSync(reader.meta.contentStartOffset);
      return Ok(await reader.read(readRaf));
    } catch (e) {
      return Err(e.toString());
    }
  }
}

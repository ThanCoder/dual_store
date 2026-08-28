import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/reader/i_content_reader.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/result_t.dart';

mixin ContentReaderLogic on IEngineLogic {
  ///
  /// supported: `TextRawContentReader`,`TextCompressContentReader`
  ///
  Future<Result<R, String>> readContent<R>(Meta meta) async {
    try {
      if (meta.contentDataType == .none || meta.contentFlag == .none) {
        return Ok<String, String>('') as Result<R, String>;
      }
      if (meta.contentDataType == .text) {
        if (meta.contentFlag == .raw) {
          return await readContentExact(TextRawContentReader(meta))
              as Result<R, String>;
        }
        if (meta.contentFlag == .compressed) {
          return await readContentExact(TextCompressContentReader(meta))
              as Result<R, String>;
        }
      }
      // if (meta.contentDataType == .json) {}

      return Err(
        'Not Supported!: contentDataType: ${meta.contentDataType} - contentFlag: ${meta.contentFlag}',
      );
    } catch (e) {
      return Err(e.toString());
    }
  }

  ///
  /// supported: `TextRawContentReader`,`TextCompressContentReader`
  ///
  Result<R, String> readContentSync<R>(Meta meta) {
    try {
      if (meta.contentDataType == .none || meta.contentFlag == .none) {
        return Ok<String, String>('') as Result<R, String>;
      }

      if (meta.contentDataType == .text) {
        if (meta.contentFlag == .raw) {
          return readContentExactSync(TextRawContentReader(meta))
              as Result<R, String>;
        }
        if (meta.contentFlag == .compressed) {
          return readContentExactSync(TextCompressContentReader(meta))
              as Result<R, String>;
        }
      }
      // if (meta.contentDataType == .json) {}
      return Err(
        'Not Supported!: contentDataType: ${meta.contentDataType} - contentFlag: ${meta.contentFlag}',
      );
    } catch (e) {
      return Err(e.toString());
    }
  }

  //***************Exac****************************** */
  /// example
  ///
  /// `await eng.readContentExact(TextRawContentReader(meta))`
  ///
  /// `await eng.readContentExact(TextCompressContentReader(meta))`
  ///
  Result<R, String> readContentExactSync<R>(IContentReader<R> reader) {
    try {
      readRaf.setPositionSync(reader.meta.contentStartOffset);
      return Ok(reader.readSync(readRaf));
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// example
  ///
  /// `eng.readContentExactSync(TextRawContentReader(meta));`
  ///
  /// `eng.readContentExactSync(TextCompressContentReader(meta));`
  ///
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

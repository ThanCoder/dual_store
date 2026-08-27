import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/interfaces/types.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/result_t.dart';

mixin MetaRemoverLogic on IEngineLogic {
  /// ### Remove Meta
  ///
  /// Synchronously flushes the contents of the file to disk.
  Result<bool, String> removeMeta(Meta meta, {bool diskFlush = true}) {
    return removeMetaById(meta.id);
  }

  /// ### Remove Meta
  ///
  /// Synchronously flushes the contents of the file to disk.
  Result<bool, String> removeMetaById(int id, {bool diskFlush = true}) {
    try {
      final size = ctx.writeRaf.lengthSync();

      if (size == 0) {
        return Ok(false);
      }
      final meta = ctx.allMeta[id];
      if (meta == null) return Ok(false);

      ctx.writeRaf.setPositionSync(meta.headerOffset);
      ctx.writeRaf.writeByteSync(DuFlag.deleted.value);

      // go end post
      ctx.writeRaf.setPositionSync(size);

      if (diskFlush) {
        ctx.writeRaf.flushSync();
      }
      // update ctx
      ctx.deletedSize += meta.totalSize;
      ctx.deletedCount += 1;
      ctx.allMeta.remove(id);
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }
}

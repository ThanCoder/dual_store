import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/interfaces/types.dart';
import 'package:dual_store/src/core/models/meta.dart';
import 'package:dual_store/src/result_t.dart';

mixin MetaRemoverLogic on IEngineLogic {
  /// ### Remove Meta
  Future<Result<bool, String>> removeMeta(
    Meta meta, {
    bool diskFlush = true,
  }) async {
    return await removeMetaById(meta.id);
  }

  /// ### Remove Meta
  ///
  Future<Result<bool, String>> removeMetaById(
    int id, {
    bool diskFlush = true,
  }) async {
    try {
      final size = await ctx.writeRaf.length();

      if (size == 0) {
        return Ok(false);
      }
      final meta = ctx.allMeta[id];
      if (meta == null) return Ok(false);

      await ctx.writeRaf.setPosition(meta.headerOffset);
      await ctx.writeRaf.writeByte(DuFlag.deleted.value);

      // go end post
      await ctx.writeRaf.setPosition(size);

      if (diskFlush) {
        await ctx.writeRaf.flush();
      }
      // update ctx
      ctx.deletedSize += meta.totalSize;
      ctx.deletedCount += 1;
      ctx.allMeta.remove(id);
      eventController.add(DeleteId(id));

      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// ### Remove Meta
  ///
  /// Synchronously flushes the contents of the file to disk.
  Result<bool, String> removeMetaSync(Meta meta, {bool diskFlush = true}) {
    return removeMetaByIdSync(meta.id);
  }

  /// ### Remove Meta
  ///
  /// Synchronously flushes the contents of the file to disk.
  Result<bool, String> removeMetaByIdSync(int id, {bool diskFlush = true}) {
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
      eventController.add(DeleteId(id));
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }
}

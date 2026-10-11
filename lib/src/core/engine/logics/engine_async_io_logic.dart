// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:dual_store/dual_store.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/engine/logics/meta_info_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/result_t.dart';

mixin EngineAsyncIoLogic on IEngineLogic {
  Result<bool, String> openAsync(String path) {
    try {
      ctx.opened = false;
      ctx.clearState();

      final file = File(path);

      final exists = file.existsSync();

      ctx.writeRaf = file.openSync(mode: FileMode.append);

      ctx.readRaf = file.openSync(mode: FileMode.read);

      if (!exists || ctx.writeRaf.lengthSync() == 0) {
        writeHeader(ctx.writeRaf, const DuHeader(magic: 'dust'));
        ctx.writeRaf.flushSync();
      }

      final headerRes = readHeader(ctx.readRaf);
      if (headerRes.isErr) {
        return Err(headerRes.unwrapError());
      }
      final metaInfoRes = getMetaInfoSync(path);
      if (metaInfoRes.isErr) {
        return Err(metaInfoRes.unwrapError());
      }
      final metaInfo = metaInfoRes.unwrap();

      ctx.header = headerRes.unwrap();
      ctx.allMeta = metaInfo.allMeta;
      ctx.lastId = metaInfo.lastId;
      ctx.deletedCount = metaInfo.deletedCount;
      ctx.deletedSize = metaInfo.deletedSize;
      ctx.opened = true;
      // adapter meta
      ctx.adapterMeta.clear();
      for (var meta in metaInfo.allMeta.values) {
        if (meta.adapterId == -1) continue;
        ctx.adapterMeta.putIfAbsent(meta.adapterId, () => {}).add(meta.id);
      }

      eventController.add(Open());

      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// close async
  Result<bool, String> closeAsync() {
    if (!ctx.onceInit) return Ok(false);
    try {
      ctx.readRaf.closeSync();
      ctx.writeRaf.closeSync();
      ctx.opened = false;
      eventController.add(Close());
      ctx.allMeta.clear();
      ctx.adapterMeta.clear();

      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Result<bool, String> flushAsync() {
    if (!ctx.onceInit) return Ok(false);
    try {
      ctx.writeRaf.flushSync();
      eventController.add(FlushToDisk());
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  /// close database && close event
  void disposeAsync() {
    closeAsync();
    eventController.close();
  }
}

import 'dart:io';

import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/result_t.dart';

mixin EngineIoLogic on IEngineLogic {
  @override
  Future<Result<bool, String>> changePath(String path) async {
    await close();
    final res = await open(path);
    if (res.isOk) {
      eventController.add(ChangePath());
    }
    return res;
  }

  Future<Result<bool, String>> reloadIfNotOpened() async {
    if (ctx.opened) return Ok(false);
    return await reload();
  }

  @override
  Future<Result<bool, String>> reload() async {
    await close();
    final res = await open(ctx.readRaf.path);
    if (res.isOk) {
      eventController.add(Reload());
    }
    return res;
  }

  @override
  Future<Result<bool, String>> open(String path) async {
    try {
      ctx.opened = false;

      final file = File(path);

      final exists = file.existsSync();

      ctx.writeRaf = file.openSync(mode: FileMode.append);

      ctx.readRaf = file.openSync(mode: FileMode.read);

      if (!exists || ctx.writeRaf.lengthSync() == 0) {
        writeHeader(ctx.writeRaf, const DuHeader(magic: 'dust'));
        await ctx.writeRaf.flush();
      }

      final headerRes = readHeader(ctx.readRaf);
      if (headerRes.isErr) {
        return Err(headerRes.unwrapError());
      }
      final metaInfoRes = await getMetaInfo(path);
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
      eventController.add(Open());

      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<bool, String>> close() async {
    try {
      await ctx.readRaf.close();
      await ctx.writeRaf.close();
      ctx.opened = false;
      eventController.add(Close());
      ctx.allMeta.clear();

      eventController.close();
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }

  @override
  Future<Result<bool, String>> flush() async {
    try {
      await ctx.writeRaf.flush();
      eventController.add(FlushToDisk());
      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:dual_store/src/core/engine/du_header_io.dart';
import 'package:dual_store/src/core/engine/events/du_event.dart';
import 'package:dual_store/src/core/engine/interfaces/i_engine_logic.dart';
import 'package:dual_store/src/core/models/du_header.dart';
import 'package:dual_store/src/result_t.dart';

typedef CompactProgress = void Function(int total, int loaded);

mixin CompactLogic on IEngineLogic {
  /// database cleanup
  Future<Result<bool, String>> compact({
    CompactProgress? onCompactProgress,
  }) async {
    if (ctx.deletedCount == 0) {
      return Ok(false);
    }

    final oldFile = File(ctx.writeRaf.path);
    final compFile = File('${oldFile.path}.cf');
    final backupFile = File('${oldFile.path}.bak');

    // Remove stale compact file.
    if (await compFile.exists()) {
      await compFile.delete();
    }

    final compRaf = await compFile.open(mode: .write);
    final readRaf = ctx.readRaf;

    try {
      // Skip old header.
      await readRaf.setPosition(duHeaderFixedLength);

      // Write new header.
      writeHeader(compRaf, const DuHeader(magic: 'dust'));

      final buffer = Uint8List(64 * 1024);

      final allTotalSize = ctx.allMeta.values.fold(
        0,
        (prev, ele) => prev + ele.totalSize,
      );
      int compactProgress = 0;

      for (final meta in ctx.allMeta.values) {
        final startPos = meta.headerOffset;
        final totalSize = meta.totalSize;

        // Read from the old record position.
        await readRaf.setPosition(startPos);

        // New offset in the compacted file.
        final newOffset = compRaf.positionSync();

        var remaining = totalSize;

        while (remaining > 0) {
          final readSize = remaining > buffer.length
              ? buffer.length
              : remaining;

          final bytes = await readRaf.read(readSize);

          if (bytes.isEmpty) {
            throw StateError('Unexpected EOF while compacting at $startPos');
          }

          await compRaf.writeFrom(bytes);

          remaining -= bytes.length;
          compactProgress += bytes.length;
          // progress
          onCompactProgress?.call(allTotalSize, compactProgress);
        }

        // Update metadata to the new position.
        // meta.headerOffset = newOffset;
        ctx.allMeta[meta.id] = meta.copyWith(headerOffset: newOffset);
      }

      // Make sure everything is written.
      await compRaf.flush();
    } catch (e) {
      await compRaf.close();

      if (await compFile.exists()) {
        await compFile.delete();
      }
      eventController.add(CompactError(e.toString()));
      return Err(e.toString());
    }

    await compRaf.close();

    // ----------------------------------------------------------
    // Replace old file
    // ----------------------------------------------------------

    try {
      // Close old RAFs before replacing the file.
      await ctx.readRaf.close();
      await ctx.writeRaf.close();

      // Remove old backup if it exists.
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      // Keep the original file as backup until replacement succeeds.
      await oldFile.rename(backupFile.path);

      try {
        // Replace old file with compacted file.
        await compFile.rename(oldFile.path);
      } catch (e) {
        // Restore original file.
        if (await oldFile.exists()) {
          await oldFile.delete();
        }

        if (await backupFile.exists()) {
          await backupFile.rename(oldFile.path);
        }

        return Err(e.toString());
      }

      // New file is successfully installed.
      await backupFile.delete();
    } catch (e) {
      eventController.add(CompactError(e.toString()));
      return Err(e.toString());
    }

    // ----------------------------------------------------------
    // Re-open RAFs
    // ----------------------------------------------------------

    try {
      ctx.readRaf = await oldFile.open(mode: .read);
      ctx.writeRaf = await oldFile.open(mode: .append);

      ctx.deletedCount = 0;
      ctx.deletedSize = 0;
      ctx.adapterMeta.clear();
      for (var meta in ctx.allMeta.values) {
        ctx.adapterMeta.putIfAbsent(meta.adapterId, () => {}).add(meta.id);
      }

      //event
      eventController.add(const CompactSuccess());

      return Ok(true);
    } catch (e) {
      return Err(e.toString());
    }
  }
}

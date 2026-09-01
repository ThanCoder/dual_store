// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dual_store/dual_store.dart';

void main() async {
  final dir = Directory('/home/thancoder/Documents');
  // await addAll(dir);
  await getAll(dir);
}

Future<void> getAll(Directory dir) async {
  final path = '${dir.path}/apyar.store';
  final st = DualStore();
  st.registerAdapter(ApyarAdapter());
  st.registerAdapter(ApyarContentAdapter());

  await st.open(path);

  final apBox = st.getBox<Apyar>();
  final conBox = st.getBox<ApyarContent>();
  final listRes = await apBox.getAll();
  if (listRes.isErr) {
    print('Error: ${listRes.unwrapError()}');
    return;
  }

  for (var ap in listRes.unwrap()) {
    print(ap.title);
    final apCon = await ap.getContent();
    print('ap content: ${apCon.unwrap()}');

    final conList = await conBox.getAll(parentId: ap.generatedId);
    final con = conList.unwrap().first;
    // final content = await conBox.getContent<String>(con);
    final content = await con.getContent<String>();
    print('content len: ${content.unwrap().length}');
    // File(ap.title).writeAsString(content.unwrap());
    return;
  }
}

Future<void> addAll(Directory dir) async {
  final path = '${dir.path}/apyar.store';
  final apyarDir = Directory('${dir.path}/apyar-files');

  final st = DualStore();
  st.registerAdapter(ApyarAdapter());
  st.registerAdapter(ApyarContentAdapter());

  await st.open(path);

  final apBox = st.getBox<Apyar>();
  final conBox = st.getBox<ApyarContent>();

  for (var f in apyarDir.listSync()) {
    final name = f.path.split('/').last;

    final content = await File(f.path).readAsString();
    final ap = Apyar(title: name, date: .now());
    final res = await apBox.add(ap, diskFlush: false);
    if (res.isOk) {
      await conBox.add(
        .new(apyarId: res.unwrap(), chapter: 1, date: .now()),
        contentWriter: TextCompressContentWriter(content),
        diskFlush: false,
      );
    }
    print('Added: $name');
  }

  await st.flush();
  print('All Writed');

  await st.close();
}

class Apyar extends IDuModel {
  final String title;
  final DateTime date;
  Apyar({required this.title, required this.date});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Apyar.fromMap(Map<String, dynamic> map) {
    return Apyar(
      title: map['title'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  @override
  String toString() => 'Apyar(title: $title, date: $date)';
}

class ApyarContent extends IDuModel {
  final int apyarId;
  final int chapter;
  final DateTime date;
  ApyarContent({
    required this.apyarId,
    required this.chapter,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'apyarId': apyarId,
      'chapter': chapter,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory ApyarContent.fromMap(Map<String, dynamic> map) {
    return ApyarContent(
      apyarId: map['apyarId'] as int,
      chapter: map['chapter'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }

  @override
  String toString() =>
      'ApyarContent(apyarId: $apyarId, chapter: $chapter, date: $date)';
}

class ApyarAdapter extends IDuBinaryMetaAdapter<Apyar> {
  @override
  Apyar fromMap(Map<String, dynamic> map) {
    return Apyar.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(Apyar value) {
    return value.toMap();
  }

  @override
  int get adapterId => 1;
}

class ApyarContentAdapter extends IDuBinaryMetaAdapter<ApyarContent> {
  @override
  ApyarContent fromMap(Map<String, dynamic> map) {
    return .fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(ApyarContent value) {
    return value.toMap();
  }

  @override
  int get adapterId => 2;

  @override
  int parentId(ApyarContent value) {
    return value.apyarId;
  }
}

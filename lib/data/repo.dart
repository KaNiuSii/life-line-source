import 'package:flutter/services.dart' as root_bundle;
import 'package:life_line/data/models/line_data.dart';
import 'package:life_line/data/models/metadata.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class Repo {
  Future<Map<String, dynamic>> loadYamlData(String path) async {
    final yamlString = await root_bundle.rootBundle.loadString(path);
    final yamlMap = loadYaml(yamlString);
    return Map<String, dynamic>.from(yamlMap);
  }

  Future<List<List<dynamic>>> loadCSVData(String path) async {
    final csvString = await root_bundle.rootBundle.loadString(path);
    return csvString
        .trim()
        .split('\n')
        .map((row) => row.split(';').map((e) => e.trim()).toList())
        .toList();
  }

  String _decryptCell(Uint8List key, String token) {
    try {
      final data = base64.decode(token);
      final nonce = data.sublist(0, 12);
      final ct = data.sublist(12);

      final params = AEADParameters(
        KeyParameter(key),
        128,
        nonce,
        Uint8List(0),
      );

      final cipher = GCMBlockCipher(AESEngine())..init(false, params);

      final out = cipher.process(ct);
      return utf8.decode(out);
    } catch (_) {
      return '???';
    }
  }

  Uint8List _passwordToKey(String password) {
    // Przytnij lub dopełnij do 32 bajtów (AES-256)
    final bytes = utf8.encode(password);
    final key = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      key[i] = i < bytes.length ? bytes[i] : 0;
    }
    return key;
  }

  Future<Metadata> loadMetadata() async {
    final yamlMap = await loadYamlData('assets/metadata.yml');
    return Metadata.fromMap(Map<String, dynamic>.from(yamlMap));
  }

  Future<List<LineData>> loadLineData(String password) async {
    final key = _passwordToKey(password);
    final csvString = await root_bundle.rootBundle.loadString(
      'assets/line_data_encrypted.csv',
    );

    final rows = csvString
        .trim()
        .split('\n')
        .map((row) => row.split(';').map((e) => e.trim()).toList())
        .toList();

    return rows.skip(1).where((row) => row.isNotEmpty && row[0].isNotEmpty).map(
      (row) {
        final age = _decryptCell(key, row[0]);
        final positive = _decryptCell(key, row[1]);
        final title = _decryptCell(key, row[2]);

        return LineData.fromMap({
          'age': double.tryParse(age) ?? 0,
          'positive':
              positive.trim() == '1' || positive.trim().toLowerCase() == 'true',
          'title': title,
        });
      },
    ).toList();
  }
}

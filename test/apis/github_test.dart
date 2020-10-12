import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:test/test.dart';

import 'package:notium/apis/githost_factory.dart';
import 'package:notium/apis/github.dart';

void main() {
  test('Parse json', () async {
    var testDataPath = '';

    var currentDir = Directory.current;
    var folderName = basename(currentDir.path);

    if (folderName == 'test') {
      testDataPath = join(currentDir.path, 'apis/data/github.json');
    } else {
      testDataPath = join(currentDir.path, 'test/apis/data/github.json');
    }

    var jsonString = File(testDataPath).readAsStringSync();

    var api = GitHub();

    List<dynamic> list = jsonDecode(jsonString);
    var repos = <GitHostRepo>[];
    list.forEach((dynamic d) {
      var map = Map<String, dynamic>.from(d);
      var repo = api.repoFromJson(map);
      repos.add(repo);
    });

    expect(repos.length, 2);
  });
}

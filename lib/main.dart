import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:simplewave/app.dart';
import 'package:simplewave/app_settings.dart';
import 'package:simplewave/error_reporting.dart';
import 'package:simplewave/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var pref = await SharedPreferences.getInstance();
  AppSettings.instance.load(pref);
  Settings.instance.load(pref);

  JournalApp.isInDebugMode = foundation.kDebugMode;
  FlutterError.onError = flutterOnErrorHandler;

  Isolate.current.addErrorListener(RawReceivePort((dynamic pair) async {
    var isolateError = pair as List<dynamic>;
    assert(isolateError.length == 2);
    assert(isolateError.first.runtimeType == Error);
    assert(isolateError.last.runtimeType == StackTrace);

    await reportError(isolateError.first, isolateError.last);
  }).sendPort);

  runZonedGuarded(() async {
    await JournalApp.main();
  }, reportError);
}

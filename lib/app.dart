import 'dart:async';
import 'dart:io';

import 'package:dart_git/git.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/material.dart';
import 'package:notium/app_settings.dart';
import 'package:notium/appstate.dart';
import 'package:notium/core/md_yaml_doc_codec.dart';
import 'package:notium/event_logger.dart';
import 'package:notium/screens/filesystem_screen.dart';
import 'package:notium/screens/folder_listing.dart';
import 'package:notium/screens/graph_view.dart';
import 'package:notium/screens/note_editor.dart';
import 'package:notium/screens/tag_listing.dart';
import 'package:notium/settings.dart';
import 'package:notium/state_container.dart';
import 'package:notium/themes.dart';
import 'package:notium/utils.dart';
import 'package:notium/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screens.dart';
import 'screens/settings_screen.dart';
import 'setup/screens.dart';

class JournalApp extends StatefulWidget {
  final AppState appState;

  static Future main() async {
    await Log.init();

    var appState = AppState();
    var settings = Settings.instance;
    var appSettings = AppSettings.instance;
    Log.i("AppSetting ${appSettings.toMap()}");
    Log.i("Setting ${settings.toLoggableMap()}");

    var dir = await getApplicationDocumentsDirectory();
    appState.gitBaseDirectory = dir.path;

    var gitRepoDir = p.join(appState.gitBaseDirectory, settings.internalRepoFolderName);

    var repoDirStat = File(gitRepoDir).statSync();
    if (repoDirStat.type != FileSystemEntityType.directory) {
      settings.internalRepoFolderName = "notium_notes";
      var repoPath = p.join(
        appState.gitBaseDirectory,
        settings.internalRepoFolderName,
      );
      Log.i("Calling GitInit at: $repoPath");
      await GitRepository.init(repoPath);

      settings.save();
    } else {
      var gitRepo = await GitRepository.load(gitRepoDir);
      var remotes = gitRepo.config.remotes;
      appState.remoteGitRepoConfigured = remotes.isNotEmpty;
    }
    final cacheDir = await getApplicationSupportDirectory();

    Widget app = ChangeNotifierProvider.value(
      value: settings,
      child: ChangeNotifierProvider(
        create: (_) {
          return StateContainer(
            appState: appState,
            settings: settings,
            gitBaseDirectory: appState.gitBaseDirectory,
            cacheDirectory: cacheDir.path,
          );
        },
        child: ChangeNotifierProvider(
          child: JournalApp(appState),
          create: (_) {
            assert(appState.notesFolder != null);
            return appState.notesFolder;
          },
        ),
      ),
    );

    app = ChangeNotifierProvider.value(
      value: appSettings,
      child: app,
    );

    runApp(EasyLocalization(
      child: app,
      supportedLocales: [
        const Locale('en', 'US'),
      ], // Remember to update Info.plist
      path: 'assets/langs',
      useOnlyLangCode: true,
      assetLoader: YamlAssetLoader(),
    ));
  }

  static bool isInDebugMode = false;

  JournalApp(this.appState);

  @override
  _JournalAppState createState() => _JournalAppState();
}

class _JournalAppState extends State<JournalApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  String _pendingShortcut;

  StreamSubscription _intentDataStreamSubscription;
  String _sharedText;
  List<String> _sharedImages;

  @override
  void initState() {
    super.initState();
    _initShareSubscriptions();
  }

  void _afterBuild(BuildContext context) {
    if (_pendingShortcut != null) {
      _navigatorKey.currentState.pushNamed("/newNote/$_pendingShortcut");
      _pendingShortcut = null;
    }
  }

  void _initShareSubscriptions() {
    var handleShare = () {
      if (_sharedText == null && _sharedImages == null) {
        return;
      }

      var settings = Provider.of<Settings>(context, listen: false);
      var editor = settings.defaultEditor.toInternalString();
      _navigatorKey.currentState.pushNamed("/newNote/$editor");
    };

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      if (value == null) return;
      Log.d("Received Share $value");

      setState(() {
        _sharedImages = value.map((f) => f.path)?.toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    }, onError: (err) {
      Log.e("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value == null) return;
      Log.d("Received Share with App running $value");

      setState(() {
        _sharedImages = value.map((f) => f.path)?.toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    });

    // For sharing or opening text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      Log.d("Received Share $value");
      setState(() {
        _sharedText = value;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    }, onError: (err) {
      Log.e("getLinkStream error: $err");
    });

    // For sharing or opening text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      Log.d("Received Share with App running $value");
      setState(() {
        _sharedText = value;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => handleShare());
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (b) => b == Brightness.light ? Themes.light : Themes.dark,
      themedWidgetBuilder: buildApp,
    );
  }

  MaterialApp buildApp(BuildContext context, ThemeData themeData) {
    var stateContainer = Provider.of<StateContainer>(context);
    var settings = Provider.of<Settings>(context);
    var appSettings = Provider.of<AppSettings>(context);

    var initialRoute = '/';
    if (!appSettings.onBoardingCompleted) {
      initialRoute = '/onBoarding';
    } else {
      if (settings.homeScreen == SettingsHomeScreen.AllFolders) {
        initialRoute = '/folders';
      }
      if (settings.homeScreen == SettingsHomeScreen.NewNote) {
        initialRoute = '/newNote/' + settings.defaultEditor.toInternalString();
      }
    }

    return MaterialApp(
      key: const ValueKey("App"),
      navigatorKey: _navigatorKey,
      title: 'Notium',

      localizationsDelegates: EasyLocalization.of(context).delegates,
      supportedLocales: EasyLocalization.of(context).supportedLocales,
      locale: EasyLocalization.of(context).locale,

      theme: themeData,
      navigatorObservers: <NavigatorObserver>[
        EventLogRouteObserver(),
      ],
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
      onGenerateRoute: (routeSettings) {
        var route = routeSettings.name;
        if (route == '/folders' || route == '/tags' || route == '/filesystem') {
          return PageRouteBuilder(
            settings: routeSettings,
            pageBuilder: (_, __, ___) =>
                _screenForRoute(route, stateContainer, settings),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          );
        }

        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => _screenForRoute(
            route,
            stateContainer,
            settings,
          ),
        );
      },
    );
  }

  Widget _screenForRoute(
    String route,
    StateContainer stateContainer,
    Settings settings,
  ) {
    switch (route) {
      case '/':
        return HomeScreen();
      case '/folders':
        return FolderListingScreen();
      case '/filesystem':
        return FileSystemScreen();
      case '/tags':
        return TagListingScreen();
      case '/graph':
        return GraphViewScreen();
      case '/settings':
        return SettingsScreen();
      case '/setupRemoteGit':
        return GitHostSetupScreen(
          repoFolderName: settings.internalRepoFolderName,
          remoteName: "origin",
          onCompletedFunction: stateContainer.completeGitHostSetup,
        );
      case '/onBoarding':
        return OnBoardingScreen();
    }

    if (route.startsWith('/newNote/')) {
      var type = route.substring('/newNote/'.length);
      var et = SettingsEditorType.fromInternalString(type).toEditorType();

      Log.i("New Note - $route");
      Log.i("EditorType: $et");

      var rootFolder = widget.appState.notesFolder;
      var sharedImages = _sharedImages;
      var sharedText = _sharedText;

      _sharedText = null;
      _sharedImages = null;

      Log.d("sharedText: $sharedText");
      Log.d("sharedImages: $sharedImages");

      var extraProps = <String, dynamic>{};
      if (settings.customMetaData.isNotEmpty) {
        var map = MarkdownYAMLCodec.parseYamlText(settings.customMetaData);
        map.forEach((key, val) {
          extraProps[key] = val;
        });
      }

      var folder = getFolderForEditor(settings, rootFolder, et);
      return NoteEditor.newNote(
        folder,
        folder,
        et,
        existingText: sharedText,
        existingImages: sharedImages,
        newNoteExtraProps: extraProps,
      );
    }

    return HomeScreen();
  }
}

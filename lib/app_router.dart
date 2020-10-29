import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:notium/app_settings.dart';
import 'package:notium/core/md_yaml_doc_codec.dart';
import 'package:notium/screens/filesystem_screen.dart';
import 'package:notium/screens/folder_listing.dart';
import 'package:notium/screens/home_screen.dart';
import 'package:notium/screens/note_editor.dart';
import 'package:notium/screens/onboarding_screens.dart';
import 'package:notium/screens/settings_screen.dart';
import 'package:notium/screens/tag_listing.dart';
import 'package:notium/settings.dart';
import 'package:notium/setup/screens.dart';
import 'package:notium/state_container.dart';
import 'package:notium/utils.dart';
import 'package:notium/utils/logger.dart';

class AppRouter {
  final AppSettings appSettings;
  final Settings settings;

  AppRouter({@required this.appSettings, @required this.settings});

  String initialRoute() {
    var route = '/';
    if (!appSettings.onBoardingCompleted) {
      route = '/onBoarding';
    } else {
      if (settings.homeScreen == SettingsHomeScreen.AllFolders) {
        route = '/folders';
      }
      if (settings.homeScreen == SettingsHomeScreen.NewNote) {
        route = '/newNote/' + settings.defaultEditor.toInternalString();
      }
    }
    return route;
  }

  Route<dynamic> generateRoute(
      RouteSettings routeSettings,
      StateContainer stateContainer,
      String sharedText,
      List<String> sharedImages,
      ) {
    var route = routeSettings.name;
    if (route == '/folders' || route == '/tags' || route == '/filesystem') {
      return PageRouteBuilder(
        settings: routeSettings,
        pageBuilder: (_, __, ___) => _screenForRoute(
          route,
          stateContainer,
          settings,
          sharedText,
          sharedImages,
        ),
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
        sharedText,
        sharedImages,
      ),
    );
  }

  Widget _screenForRoute(
      String route,
      StateContainer stateContainer,
      Settings settings,
      String sharedText,
      List<String> sharedImages,
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
      case '/settings':
        return SettingsScreen();
      case '/setupRemoteGit':
        return GitHostSetupScreen(
          repoFolderName: settings.folderName,
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

      var rootFolder = stateContainer.appState.notesFolder;

      sharedText = null;
      sharedImages = null;

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
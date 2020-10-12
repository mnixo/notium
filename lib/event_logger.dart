import 'package:flutter/material.dart';
import 'package:notium/error_reporting.dart';
import 'package:notium/utils/logger.dart';

enum Event {
  NoteAdded,
  NoteUpdated,
  NoteDeleted,
  NoteUndoDeleted,
  NoteRenamed,
  NoteMoved,
  FileRenamed,
  FolderAdded,
  FolderDeleted,
  FolderRenamed,
  FolderConfigUpdated,
  RepoSynced,

  DrawerSetupGitHost,
  DrawerBugReport,
  DrawerSettings,

  GitHostSetupError,
  GitHostSetupComplete,
  GitHostSetupGitCloneError,
  GitHostSetupButtonClick,

  Settings,
}

String _eventToString(Event e) {
  switch (e) {
    case Event.NoteAdded:
      return "note_added";
    case Event.NoteUpdated:
      return "note_updated";
    case Event.NoteDeleted:
      return "note_deleted";
    case Event.NoteUndoDeleted:
      return "note_undo_deleted";
    case Event.NoteRenamed:
      return "note_renamed";
    case Event.NoteMoved:
      return "note_moved";

    case Event.FileRenamed:
      return "file_renamed";

    case Event.FolderAdded:
      return "folder_added";
    case Event.FolderDeleted:
      return "folder_deleted";
    case Event.FolderRenamed:
      return "folder_renamed";
    case Event.FolderConfigUpdated:
      return "folder_config_updated";

    case Event.RepoSynced:
      return "repo_synced";

    case Event.DrawerSetupGitHost:
      return "drawer_setupGitHost";
    case Event.DrawerBugReport:
      return "drawer_bugreport";
    case Event.DrawerSettings:
      return "drawer_settings";

    case Event.GitHostSetupError:
      return "githostsetup_error";
    case Event.GitHostSetupComplete:
      return "onboarding_complete";
    case Event.GitHostSetupGitCloneError:
      return "onboarding_gitClone_error";
    case Event.GitHostSetupButtonClick:
      return "githostsetup_button_click";

    case Event.Settings:
      return "settings";
  }

  return "unknown_event: " + e.toString();
}

void logEvent(Event event, {Map<String, String> parameters = const {}}) {
  Log.d("Event $event");
  Log.d("Parameters: $parameters");
  Log.d("------------");
}

class EventLogRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _logScreenView(PageRoute<dynamic> route) async {
    var screenName = route.settings.name;
    if (route.runtimeType.toString().startsWith("_SearchPageRoute")) {
      screenName = "/search";
    }

    assert(screenName != null, "Screen name is null $route");
    if (screenName == null) {
      logExceptionWarning(Exception('Route Name is Empty'), StackTrace.current);
      return;
    }

    Log.d("Screen view: $route " + screenName);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _logScreenView(route);
    } else {
      // print("route in not a PageRoute! $route");
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _logScreenView(newRoute);
    } else {
      // print("newRoute in not a PageRoute! $newRoute");
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _logScreenView(previousRoute);
    } else {
      // print("previousRoute in not a PageRoute! $previousRoute");
      // print("route in not a PageRoute! $route");
    }
  }
}

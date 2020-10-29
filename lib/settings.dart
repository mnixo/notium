import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:notium/core/sorting_mode.dart';
import 'package:notium/folder_views/common.dart';
import 'package:notium/screens/note_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  // singleton
  static final Settings _singleton = Settings._internal();
  factory Settings() => _singleton;
  Settings._internal();
  static Settings get instance => _singleton;

  // Properties
  String gitAuthor = "Notium";
  String gitAuthorEmail = "notium.app@gmail.com";
  NoteFileNameFormat noteFileNameFormat = NoteFileNameFormat.Default;

  String yamlModifiedKey = "modified";
  String yamlCreatedKey = "created";
  String yamlTagsKey = "tags";
  String customMetaData = "";

  bool yamlHeaderEnabled = true;
  String defaultNewNoteFolderSpec = "";
  String journalEditordefaultNewNoteFolderSpec = "";

  RemoteSyncFrequency remoteSyncFrequency = RemoteSyncFrequency.Default;
  SortingField sortingField = SortingField.Default;
  SortingOrder sortingOrder = SortingOrder.Default;
  SettingsEditorType defaultEditor = SettingsEditorType.Default;
  SettingsFolderViewType defaultView = SettingsFolderViewType.Default;
  bool showNoteSummary = true;
  String folderViewHeaderType = "TitleGenerated";
  int version = 0;

  SettingsHomeScreen homeScreen = SettingsHomeScreen.Default;

  SettingsMarkdownDefaultView markdownDefaultView =
      SettingsMarkdownDefaultView.Default;
  SettingsMarkdownDefaultView markdownLastUsedView =
      SettingsMarkdownDefaultView.Edit;

  String imageLocationSpec = ".notium_img";

  bool zenMode = true;
  bool saveTitleInH1 = false;

  bool swipeToDelete = true;
  bool emojiParser = true;

  Set<String> inlineTagPrefixes = {'#', '@'};

  String folderName = "notium_notes";

  String sshPublicKey = "";
  String sshPrivateKey = "";
  String sshPassword = "";

  void load(SharedPreferences pref) {
    gitAuthor = pref.getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = pref.getString("gitAuthorEmail") ?? gitAuthorEmail;

    noteFileNameFormat = NoteFileNameFormat.fromInternalString(
        pref.getString("noteFileNameFormat"));

    yamlModifiedKey = pref.getString("yamlModifiedKey") ?? yamlModifiedKey;
    yamlCreatedKey = pref.getString("yamlCreatedKey") ?? yamlCreatedKey;
    yamlTagsKey = pref.getString("yamlTagsKey") ?? yamlTagsKey;
    customMetaData = pref.getString("customMetaData") ?? customMetaData;

    yamlHeaderEnabled = pref.getBool("yamlHeaderEnabled") ?? yamlHeaderEnabled;
    defaultNewNoteFolderSpec =
        pref.getString("defaultNewNoteFolderSpec") ?? defaultNewNoteFolderSpec;

    remoteSyncFrequency = RemoteSyncFrequency.fromInternalString(
        pref.getString("remoteSyncFrequency"));

    sortingField =
        SortingField.fromInternalString(pref.getString("sortingField"));
    sortingOrder =
        SortingOrder.fromInternalString(pref.getString("sortingOrder"));
    defaultEditor =
        SettingsEditorType.fromInternalString(pref.getString("defaultEditor"));
    defaultView = SettingsFolderViewType.fromInternalString(
        pref.getString("defaultView"));

    markdownDefaultView = SettingsMarkdownDefaultView.fromInternalString(
        pref.getString("markdownDefaultView"));

    showNoteSummary = pref.getBool("showNoteSummary") ?? showNoteSummary;
    folderViewHeaderType =
        pref.getString("folderViewHeaderType") ?? folderViewHeaderType;

    version = pref.getInt("settingsVersion") ?? version;
    emojiParser = pref.getBool("emojiParser") ?? emojiParser;

    homeScreen =
        SettingsHomeScreen.fromInternalString(pref.getString("homeScreen"));

    imageLocationSpec =
        pref.getString("imageLocationSpec") ?? imageLocationSpec;

    zenMode = pref.getBool("zenMode") ?? zenMode;
    saveTitleInH1 = pref.getBool("saveTitleInH1") ?? saveTitleInH1;
    swipeToDelete = pref.getBool("swipeToDelete") ?? swipeToDelete;

    inlineTagPrefixes =
        pref.getStringList("inlineTagPrefixes")?.toSet() ?? inlineTagPrefixes;

    // From AppState
    folderName = pref.getString("remoteGitRepoPath") ?? folderName;

    sshPublicKey = pref.getString("sshPublicKey") ?? sshPublicKey;
    sshPrivateKey = pref.getString("sshPrivateKey") ?? sshPrivateKey;
    sshPassword = pref.getString("sshPassword") ?? sshPassword;
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = Settings._internal();

    _setString(pref, "gitAuthor", gitAuthor, defaultSet.gitAuthor);
    _setString(
        pref, "gitAuthorEmail", gitAuthorEmail, defaultSet.gitAuthorEmail);
    _setString(
        pref,
        "noteFileNameFormat",
        noteFileNameFormat.toInternalString(),
        defaultSet.noteFileNameFormat.toInternalString());
    _setString(
        pref, "yamlModifiedKey", yamlModifiedKey, defaultSet.yamlModifiedKey);
    _setString(
        pref, "yamlCreatedKey", yamlCreatedKey, defaultSet.yamlCreatedKey);
    _setString(pref, "yamlTagsKey", yamlTagsKey, defaultSet.yamlTagsKey);
    _setString(
        pref, "customMetaData", customMetaData, defaultSet.customMetaData);
    _setBool(pref, "yamlHeaderEnabled", yamlHeaderEnabled,
        defaultSet.yamlHeaderEnabled);
    _setString(pref, "defaultNewNoteFolderSpec", defaultNewNoteFolderSpec,
        defaultSet.defaultNewNoteFolderSpec);
    _setString(
        pref,
        "remoteSyncFrequency",
        remoteSyncFrequency.toInternalString(),
        defaultSet.remoteSyncFrequency.toInternalString());
    _setString(pref, "sortingField", sortingField.toInternalString(),
        defaultSet.sortingField.toInternalString());
    _setString(pref, "sortingOrder", sortingOrder.toInternalString(),
        defaultSet.sortingOrder.toInternalString());
    _setString(pref, "defaultEditor", defaultEditor.toInternalString(),
        defaultSet.defaultEditor.toInternalString());
    _setString(pref, "defaultView", defaultView.toInternalString(),
        defaultSet.defaultView.toInternalString());
    _setString(
        pref,
        "markdownDefaultView",
        markdownDefaultView.toInternalString(),
        defaultSet.markdownDefaultView.toInternalString());
    _setString(
        pref,
        "markdownLastUsedView",
        markdownLastUsedView.toInternalString(),
        defaultSet.markdownLastUsedView.toInternalString());
    _setBool(
        pref, "showNoteSummary", showNoteSummary, defaultSet.showNoteSummary);
    _setString(pref, "folderViewHeaderType", folderViewHeaderType,
        defaultSet.folderViewHeaderType);
    _setBool(pref, "emojiParser", emojiParser, defaultSet.emojiParser);
    _setString(pref, "homeScreen", homeScreen.toInternalString(),
        defaultSet.homeScreen.toInternalString());
    _setString(pref, "imageLocationSpec", imageLocationSpec,
        defaultSet.imageLocationSpec);
    _setBool(pref, "zenMode", zenMode, defaultSet.zenMode);
    _setBool(pref, "saveTitleInH1", saveTitleInH1, defaultSet.saveTitleInH1);
    _setBool(pref, "swipeToDelete", swipeToDelete, defaultSet.swipeToDelete);
    _setStringSet(pref, "inlineTagPrefixes", inlineTagPrefixes,
        defaultSet.inlineTagPrefixes);

    _setString(pref, "sshPublicKey", sshPublicKey, defaultSet.sshPublicKey);
    _setString(pref, "sshPrivateKey", sshPrivateKey, defaultSet.sshPrivateKey);
    _setString(pref, "sshPassword", sshPassword, defaultSet.sshPassword);

    pref.setInt("settingsVersion", version);

    pref.setString("localGitRepoPath", folderName);

    notifyListeners();
  }

  Future<void> _setString(
    SharedPreferences pref,
    String key,
    String value,
    String defaultValue,
  ) async {
    if (value == defaultValue) {
      await pref.remove(key);
    } else {
      await pref.setString(key, value);
    }
  }

  Future<void> _setBool(
    SharedPreferences pref,
    String key,
    bool value,
    bool defaultValue,
  ) async {
    if (value == defaultValue) {
      await pref.remove(key);
    } else {
      await pref.setBool(key, value);
    }
  }

  Future<void> _setStringSet(
    SharedPreferences pref,
    String key,
    Set<String> value,
    Set<String> defaultValue,
  ) async {
    final eq = const SetEquality().equals;

    if (eq(value, defaultValue)) {
      await pref.remove(key);
    } else {
      await pref.setStringList(key, value.toList());
    }
  }

  Map<String, String> toMap() {
    return <String, String>{
      "gitAuthor": gitAuthor,
      "gitAuthorEmail": gitAuthorEmail,
      "noteFileNameFormat": noteFileNameFormat.toInternalString(),
      "yamlModifiedKey": yamlModifiedKey,
      "yamlCreatedKey": yamlCreatedKey,
      "yamlTagsKey": yamlTagsKey,
      "customMetaData": customMetaData,
      "yamlHeaderEnabled": yamlHeaderEnabled.toString(),
      "defaultNewNoteFolderSpec": defaultNewNoteFolderSpec,
      "defaultEditor": defaultEditor.toInternalString(),
      "defaultView": defaultView.toInternalString(),
      "sortingField": sortingField.toInternalString(),
      "sortingOrder": sortingOrder.toInternalString(),
      "remoteSyncFrequency": remoteSyncFrequency.toInternalString(),
      "showNoteSummary": showNoteSummary.toString(),
      "folderViewHeaderType": folderViewHeaderType,
      "version": version.toString(),
      'markdownDefaultView': markdownDefaultView.toInternalString(),
      'markdownLastUsedView': markdownLastUsedView.toInternalString(),
      'homeScreen': homeScreen.toInternalString(),
      'imageLocationSpec': imageLocationSpec,
      'zenMode': zenMode.toString(),
      'saveTitleInH1': saveTitleInH1.toString(),
      'swipeToDelete': swipeToDelete.toString(),
      'inlineTagPrefixes': inlineTagPrefixes.join(' '),
      'emojiParser': emojiParser.toString(),
      'remoteGitRepoPath': folderName.toString(),
      'sshPublicKey': sshPublicKey.isNotEmpty.toString(),
    };
  }

  Map<String, String> toLoggableMap() {
    var m = toMap();
    m.remove("gitAuthor");
    m.remove("gitAuthorEmail");
    m.remove("defaultNewNoteFolderSpec");
    return m;
  }
}

class NoteFileNameFormat {
  static const Iso8601WithTimeZone = NoteFileNameFormat(
      "Iso8601WithTimeZone", 'settings.NoteFileNameFormat.iso8601WithTimeZone');
  static const Iso8601 =
      NoteFileNameFormat("Iso8601", 'settings.NoteFileNameFormat.iso8601');
  static const Iso8601WithTimeZoneWithoutColon = NoteFileNameFormat(
      "Iso8601WithTimeZoneWithoutColon",
      'settings.NoteFileNameFormat.iso8601WithoutColon');
  static const FromTitle =
      NoteFileNameFormat("FromTitle", 'settings.NoteFileNameFormat.title');
  static const SimpleDate =
      NoteFileNameFormat("SimpleDate", 'settings.NoteFileNameFormat.simple');
  static const UuidV4 =
      NoteFileNameFormat("uuidv4", 'settings.NoteFileNameFormat.uuid');
  static const Zettelkasten = NoteFileNameFormat(
      "Zettelkasten", 'settings.NoteFileNameFormat.zettelkasten');

  static const Default = Iso8601WithTimeZoneWithoutColon;

  static const options = <NoteFileNameFormat>[
    SimpleDate,
    FromTitle,
    Iso8601,
    Iso8601WithTimeZone,
    Iso8601WithTimeZoneWithoutColon,
    UuidV4,
    Zettelkasten,
  ];

  static NoteFileNameFormat fromInternalString(String str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static NoteFileNameFormat fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  final String _str;
  final String _publicStr;

  const NoteFileNameFormat(this._str, this._publicStr);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicStr);
  }

  @override
  String toString() {
    assert(false, "NoteFileNameFormat toString should never be called");
    return "";
  }
}

class RemoteSyncFrequency {
  static const Automatic =
      RemoteSyncFrequency("settings.remoteSync.auto", "automatic");
  static const Manual =
      RemoteSyncFrequency("settings.remoteSync.manual", "manual");
  static const Default = Automatic;

  final String _str;
  final String _publicString;
  const RemoteSyncFrequency(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <RemoteSyncFrequency>[
    Automatic,
    Manual,
  ];

  static RemoteSyncFrequency fromInternalString(String str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static RemoteSyncFrequency fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "RemoteSyncFrequency toString should never be called");
    return "";
  }
}

class SettingsEditorType {
  static const Markdown =
      SettingsEditorType('settings.editors.markdownEditor', "Markdown");
  static const Checklist =
      SettingsEditorType('settings.editors.checklistEditor', "Checklist");
  static const Default = Markdown;

  final String _str;
  final String _publicString;
  const SettingsEditorType(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  EditorType toEditorType() {
    switch (this) {
      case Markdown:
        return EditorType.Markdown;
      case Checklist:
        return EditorType.Checklist;
      default:
        return EditorType.Markdown;
    }
  }

  static SettingsEditorType fromEditorType(EditorType editorType) {
    switch (editorType) {
      case EditorType.Checklist:
        return SettingsEditorType.Checklist;
      case EditorType.Markdown:
        return SettingsEditorType.Markdown;
    }
    return SettingsEditorType.Default;
  }

  static const options = <SettingsEditorType>[
    Markdown,
    Checklist,
  ];

  static SettingsEditorType fromInternalString(String str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsEditorType fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "EditorType toString should never be called");
    return "";
  }
}

class SettingsFolderViewType {
  static const Grid =
      SettingsFolderViewType('widgets.FolderView.views.grid', "Grid");
  static const Default = Grid;

  final String _str;
  final String _publicString;
  const SettingsFolderViewType(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsFolderViewType>[
    Grid,
  ];

  static SettingsFolderViewType fromInternalString(String str) {
    return Default;
  }

  static SettingsFolderViewType fromPublicString(String str) {
    return Default;
  }

  @override
  String toString() {
    assert(false, "FolderViewType toString should never be called");
    return "";
  }

  FolderViewType toFolderViewType() {
    return FolderViewType.Grid;
  }

  static SettingsFolderViewType fromFolderViewType(FolderViewType viewType) {
    return SettingsFolderViewType.Grid;
  }
}

class SettingsMarkdownDefaultView {
  static const Edit =
      SettingsMarkdownDefaultView('settings.EditorDefaultView.edit', "Edit");
  static const Default = Edit;

  final String _str;
  final String _publicStr;
  const SettingsMarkdownDefaultView(this._publicStr, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicStr);
  }

  static const options = <SettingsMarkdownDefaultView>[
    Edit,
  ];

  static SettingsMarkdownDefaultView fromInternalString(String str) {
    return Default;
  }

  static SettingsMarkdownDefaultView fromPublicString(String str) {
    return Default;
  }

  @override
  String toString() {
    assert(
        false, "SettingsMarkdownDefaultView toString should never be called");
    return "";
  }
}

class SettingsHomeScreen {
  static const NewNote =
    SettingsHomeScreen("settings.HomeScreen.newNote", "new_note");
  static const AllNotes =
    SettingsHomeScreen("settings.HomeScreen.allNotes", "all_notes");
  static const AllFolders =
    SettingsHomeScreen("settings.HomeScreen.allFolders", "all_folders");
  static const Default = NewNote;

  final String _str;
  final String _publicString;
  const SettingsHomeScreen(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SettingsHomeScreen>[
    NewNote,
    AllNotes,
    AllFolders,
  ];

  static SettingsHomeScreen fromInternalString(String str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SettingsHomeScreen fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "SettingsHomeScreen toString should never be called");
    return "";
  }
}

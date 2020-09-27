import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_serializer/yaml_serializer.dart';

import 'package:simplewave/core/notes_folder_fs.dart';
import 'package:simplewave/core/sorting_mode.dart';
import 'package:simplewave/folder_views/common.dart';
import 'package:simplewave/folder_views/standard_view.dart';
import 'package:simplewave/screens/note_editor.dart';
import 'package:simplewave/settings.dart';
import 'package:simplewave/utils/logger.dart';

@immutable
class NotesFolderConfig extends Equatable {
  static const FILENAME = ".gitjournal.yaml";

  final SortingMode sortingMode;
  final EditorType defaultEditor;
  final FolderViewType defaultView;

  final StandardViewHeader viewHeader;
  final bool showNoteSummary;
  final NoteFileNameFormat fileNameFormat;
  final NotesFolderFS folder;
  final bool yamlHeaderEnabled;
  //int _version = 1;

  final String yamlModifiedKey;
  final String yamlCreatedKey;
  final String yamlTagsKey;
  final bool saveTitleInH1;

  NotesFolderConfig({
    @required this.sortingMode,
    @required this.defaultEditor,
    @required this.defaultView,
    @required this.viewHeader,
    @required this.showNoteSummary,
    @required this.fileNameFormat,
    @required this.folder,
    @required this.yamlHeaderEnabled,
    @required this.yamlModifiedKey,
    @required this.yamlCreatedKey,
    @required this.yamlTagsKey,
    @required this.saveTitleInH1,
  });

  @override
  List<Object> get props => [
        sortingMode,
        defaultEditor,
        defaultView,
        viewHeader,
        fileNameFormat,
        folder,
        yamlHeaderEnabled,
        yamlModifiedKey,
        yamlCreatedKey,
        yamlTagsKey,
        saveTitleInH1,
      ];

  static NotesFolderConfig fromSettings(NotesFolderFS folder) {
    var settings = Settings.instance;

    StandardViewHeader viewHeader;
    switch (settings.folderViewHeaderType) {
      case "TitleGenerated":
        viewHeader = StandardViewHeader.TitleGenerated;
        break;
      case "FileName":
        viewHeader = StandardViewHeader.FileName;
        break;
      case "TitleOrFileName":
        viewHeader = StandardViewHeader.TitleOrFileName;
        break;
    }

    return NotesFolderConfig(
      defaultEditor: settings.defaultEditor.toEditorType(),
      defaultView: settings.defaultView.toFolderViewType(),
      sortingMode: SortingMode(settings.sortingField, settings.sortingOrder),
      showNoteSummary: settings.showNoteSummary,
      viewHeader: viewHeader,
      fileNameFormat: settings.noteFileNameFormat,
      folder: folder,
      yamlHeaderEnabled: settings.yamlHeaderEnabled,
      yamlCreatedKey: settings.yamlCreatedKey,
      yamlModifiedKey: settings.yamlModifiedKey,
      yamlTagsKey: settings.yamlTagsKey,
      saveTitleInH1: settings.saveTitleInH1,
    );
  }

  Future<void> saveToSettings() async {
    var settings = Settings.instance;

    settings.sortingField = sortingMode.field;
    settings.sortingOrder = sortingMode.order;
    settings.showNoteSummary = showNoteSummary;
    settings.defaultEditor = SettingsEditorType.fromEditorType(defaultEditor);
    settings.defaultView =
        SettingsFolderViewType.fromFolderViewType(defaultView);

    String ht;
    switch (viewHeader) {
      case StandardViewHeader.FileName:
        ht = "FileName";
        break;
      case StandardViewHeader.TitleGenerated:
        ht = "TitleGenerated";
        break;
      case StandardViewHeader.TitleOrFileName:
        ht = "TitleOrFileName";
        break;
    }
    settings.folderViewHeaderType = ht;
    settings.noteFileNameFormat = fileNameFormat;
    settings.yamlHeaderEnabled = yamlHeaderEnabled;
    settings.yamlCreatedKey = yamlCreatedKey;
    settings.yamlModifiedKey = yamlModifiedKey;
    settings.yamlTagsKey = yamlTagsKey;
    settings.saveTitleInH1 = saveTitleInH1;
    settings.save();
  }

  NotesFolderConfig copyWith({
    SortingMode sortingMode,
    EditorType defaultEditor,
    FolderViewType defaultView,
    StandardViewHeader viewHeader,
    bool showNoteSummary,
    NoteFileNameFormat fileNameFormat,
    NotesFolderFS folder,
    bool yamlHeaderEnabled,
    String yamlCreatedKey,
    String yamlModifiedKey,
    String yamlTagsKey,
    bool saveTitleInH1,
  }) {
    return NotesFolderConfig(
      sortingMode: sortingMode ?? this.sortingMode,
      defaultEditor: defaultEditor ?? this.defaultEditor,
      defaultView: defaultView ?? this.defaultView,
      viewHeader: viewHeader ?? this.viewHeader,
      showNoteSummary: showNoteSummary ?? this.showNoteSummary,
      fileNameFormat: fileNameFormat ?? this.fileNameFormat,
      folder: folder ?? this.folder,
      yamlHeaderEnabled: yamlHeaderEnabled ?? this.yamlHeaderEnabled,
      yamlCreatedKey: yamlCreatedKey ?? this.yamlCreatedKey,
      yamlModifiedKey: yamlModifiedKey ?? this.yamlModifiedKey,
      yamlTagsKey: yamlTagsKey ?? this.yamlTagsKey,
      saveTitleInH1: saveTitleInH1 ?? this.saveTitleInH1,
    );
  }

  static Future<NotesFolderConfig> fromFS(NotesFolderFS folder) async {
    var file = File(p.join(folder.folderPath, FILENAME));
    if (!file.existsSync()) {
      return null;
    }

    var map = <String, dynamic>{};
    var contents = await file.readAsString();
    try {
      var yamlMap = loadYaml(contents);
      yamlMap.forEach((key, value) {
        map[key] = value;
      });
    } catch (err) {
      Log.d('NotesFolderConfig::decode("$contents") -> ${err.toString()}');
    }

    var sortingField =
        SortingField.fromInternalString(map["sortingField"]?.toString());
    var sortingOrder =
        SortingOrder.fromInternalString(map["sortingOrder"]?.toString());
    var sortingMode = SortingMode(sortingField, sortingOrder);

    var defaultEditor =
        SettingsEditorType.fromInternalString(map["defaultEditor"]?.toString());
    var defaultView = SettingsFolderViewType.fromInternalString(
        map["defaultView"]?.toString());

    var showNoteSummary = map["showNoteSummary"].toString() != "false";

    var folderViewHeaderType = map["folderViewHeaderType"]?.toString();
    StandardViewHeader viewHeader;
    switch (folderViewHeaderType) {
      case "TitleGenerated":
        viewHeader = StandardViewHeader.TitleGenerated;
        break;
      case "FileName":
        viewHeader = StandardViewHeader.FileName;
        break;
      case "TitleOrFileName":
        viewHeader = StandardViewHeader.TitleOrFileName;
        break;
    }

    var fileNameFormat = map['noteFileNameFormat']?.toString();
    var yamlHeaderEnabled = map["yamlHeaderEnabled"]?.toString() != "false";

    var yamlCreatedKey = map['yamlCreatedKey']?.toString();
    var yamlModifiedKey = map['yamlModifiedKey']?.toString();
    var yamlTagsKey = map['yamlTagsKey']?.toString();
    var saveTitleInH1 = map['saveTitleInH1']?.toString() != "false";

    return NotesFolderConfig(
      defaultEditor: defaultEditor.toEditorType(),
      defaultView: defaultView.toFolderViewType(),
      sortingMode: sortingMode,
      showNoteSummary: showNoteSummary,
      viewHeader: viewHeader,
      fileNameFormat: NoteFileNameFormat.fromInternalString(fileNameFormat),
      folder: folder,
      yamlHeaderEnabled: yamlHeaderEnabled,
      yamlCreatedKey: yamlCreatedKey,
      yamlModifiedKey: yamlModifiedKey,
      yamlTagsKey: yamlTagsKey,
      saveTitleInH1: saveTitleInH1,
    );
  }

  Future<void> saveToFS() async {
    String ht;
    switch (viewHeader) {
      case StandardViewHeader.FileName:
        ht = "FileName";
        break;
      case StandardViewHeader.TitleGenerated:
        ht = "TitleGenerated";
        break;
      case StandardViewHeader.TitleOrFileName:
        ht = "TitleOrFileName";
        break;
    }

    var map = <String, dynamic>{
      "sortingField": sortingMode.field.toInternalString(),
      "sortingOrder": sortingMode.order.toInternalString(),
      "defaultEditor":
          SettingsEditorType.fromEditorType(defaultEditor).toInternalString(),
      "defaultView": SettingsFolderViewType.fromFolderViewType(defaultView)
          .toInternalString(),
      "showNoteSummary": showNoteSummary,
      "folderViewHeaderType": ht,
      "noteFileNameFormat": fileNameFormat.toInternalString(),
      'yamlHeaderEnabled': yamlHeaderEnabled,
      'yamlModifiedKey': yamlModifiedKey,
      'yamlCreatedKey': yamlCreatedKey,
      'yamlTagsKey': yamlTagsKey,
      'saveTitleInH1': saveTitleInH1,
    };

    var yaml = toYAML(map);

    var file = File(p.join(folder.folderPath, FILENAME));
    await file.writeAsString(yaml);
  }
}

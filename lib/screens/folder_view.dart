import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:notium/appstate.dart';
import 'package:provider/provider.dart';
import 'package:notium/core/md_yaml_doc_codec.dart';
import 'package:notium/core/note.dart';
import 'package:notium/core/notes_folder.dart';
import 'package:notium/core/notes_folder_fs.dart';
import 'package:notium/core/sorted_notes_folder.dart';
import 'package:notium/core/sorting_mode.dart';
import 'package:notium/folder_views/common.dart';
import 'package:notium/folder_views/standard_view.dart';
import 'package:notium/screens/note_editor.dart';
import 'package:notium/screens/settings_screen.dart';
import 'package:notium/settings.dart';
import 'package:notium/state_container.dart';
import 'package:notium/utils.dart';
import 'package:notium/widgets/app_bar_menu_button.dart';
import 'package:notium/widgets/app_drawer.dart';
import 'package:notium/widgets/new_note_nav_bar.dart';
import 'package:notium/widgets/note_delete_dialog.dart';
import 'package:notium/widgets/note_search_delegate.dart';
import 'package:notium/widgets/sync_button.dart';

class FolderView extends StatefulWidget {
  final NotesFolder notesFolder;
  final Map<String, dynamic> newNoteExtraProps;

  FolderView({
    @required this.notesFolder,
    this.newNoteExtraProps = const {},
  });

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  SortedNotesFolder sortedNotesFolder;
  FolderViewType _viewType = FolderViewType.Grid;

  StandardViewHeader _headerType = StandardViewHeader.TitleGenerated;
  bool _showSummary = true;

  bool inSelectionMode = false;
  Note selectedNote;

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    sortedNotesFolder = SortedNotesFolder(
      folder: widget.notesFolder,
      sortingMode: widget.notesFolder.config.sortingMode,
    );

    _viewType = widget.notesFolder.config.defaultView;
    _showSummary = widget.notesFolder.config.showNoteSummary;
    _headerType = widget.notesFolder.config.viewHeader;
  }

  @override
  Widget build(BuildContext context) {
    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () => _newPost(widget.notesFolder.config.defaultEditor),
      child: const Icon(Icons.add),
    );

    var title = widget.notesFolder.publicName;
    if (inSelectionMode) {
      title = NumberFormat.compact().format(1);
    }

    Widget folderView = Builder(
      builder: (BuildContext context) {
        return buildFolderView(
          viewType: _viewType,
          folder: sortedNotesFolder,
          emptyText: tr('screens.folder_view.empty'),
          header: _headerType,
          showSummary: _showSummary,
          noteTapped: (Note note) {
            if (!inSelectionMode) {
              openNoteEditor(context, note, widget.notesFolder);
            } else {
              _resetSelection();
            }
          },
          noteLongPressed: (Note note) {
            setState(() {
              inSelectionMode = true;
              selectedNote = note;
            });
          },
          isNoteSelected: (n) => n == selectedNote,
          searchTerm: "",
        );
      },
    );

    // So the FAB doesn't hide parts of the last entry
    folderView = Padding(
      child: folderView,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 48.0),
    );

    var backButton = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: _resetSelection,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        leading: inSelectionMode ? backButton : GJAppBarMenuButton(),
        actions: inSelectionMode
            ? _buildInSelectionNoteActions()
            : _buildNoteActions(),
      ),
      body: Center(
        child: Builder(
          builder: (context) => RefreshIndicator(
            child: Scrollbar(child: folderView),
            onRefresh: () async => _syncRepo(context),
          ),
        ),
      ),
      extendBody: true,
      drawer: AppDrawer(),
      floatingActionButton: createButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: NewNoteNavBar(onPressed: _newPost),
    );
  }

  void _syncRepo(BuildContext context) async {
    try {
      var container = Provider.of<StateContainer>(context, listen: false);
      await container.syncNotes();
    } on GitException catch (e) {
      showSnackbar(
        context,
        tr('widgets.FolderView.syncError', args: [e.cause]),
      );
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  void _newPost(EditorType editorType) async {
    var folder = widget.notesFolder;
    NotesFolderFS fsFolder = folder.fsFolder;
    var isVirtualFolder = folder.name != folder.fsFolder.name;
    if (isVirtualFolder) {
      var rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
      var settings = Provider.of<Settings>(context, listen: false);

      fsFolder = getFolderForEditor(settings, rootFolder, editorType);
    }

    var settings = Provider.of<Settings>(context, listen: false);

    var routeType =
        SettingsEditorType.fromEditorType(editorType).toInternalString();

    var extraProps = Map<String, dynamic>.from(widget.newNoteExtraProps);
    if (settings.customMetaData.isNotEmpty) {
      var map = MarkdownYAMLCodec.parseYamlText(settings.customMetaData);
      map.forEach((key, val) {
        extraProps[key] = val;
      });
    }
    var route = MaterialPageRoute(
      builder: (context) => NoteEditor.newNote(
        fsFolder,
        widget.notesFolder,
        editorType,
        newNoteExtraProps: extraProps,
      ),
      settings: RouteSettings(name: '/newNote/$routeType'),
    );
    await Navigator.of(context).push(route);
    _scaffoldKey.currentState.removeCurrentSnackBar();
  }

  void _configureViewButtonPressed() async {
    await showDialog<SortingMode>(
      context: context,
      builder: (BuildContext context) {
        var headerTypeChanged = (StandardViewHeader newHeader) {
          setState(() {
            _headerType = newHeader;
          });

          sortedNotesFolder.config = sortedNotesFolder.config.copyWith(
            viewHeader: _headerType,
          );
        };

        var summaryChanged = (bool newVal) {
          setState(() {
            _showSummary = newVal;
          });

          sortedNotesFolder.config = sortedNotesFolder.config.copyWith(
            showNoteSummary: newVal,
          );
        };

        return StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            var children = <Widget>[
              SettingsHeader(tr('widgets.FolderView.headerOptions.heading')),
              RadioListTile<StandardViewHeader>(
                title:
                    Text(tr('widgets.FolderView.headerOptions.titleFileName')),
                value: StandardViewHeader.TitleOrFileName,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              RadioListTile<StandardViewHeader>(
                title: Text(tr('widgets.FolderView.headerOptions.auto')),
                value: StandardViewHeader.TitleGenerated,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              RadioListTile<StandardViewHeader>(
                title: Text(tr('widgets.FolderView.headerOptions.fileName')),
                value: StandardViewHeader.FileName,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: Text(tr('widgets.FolderView.headerOptions.summary')),
                value: _showSummary,
                onChanged: (bool newVal) {
                  setState(() {
                    _showSummary = newVal;
                  });
                  summaryChanged(newVal);
                },
              ),
            ];

            return AlertDialog(
              title: Text(tr('widgets.FolderView.headerOptions.customize')),
              content: Column(
                children: children,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            );
          },
        );
      },
    );

    setState(() {});
  }

  List<Widget> _buildNoteActions() {
    final appState = Provider.of<StateContainer>(context).appState;

    return <Widget>[
      if (appState.remoteGitRepoConfigured)
        AnimatedOpacity(
          opacity: Provider.of<StateContainer>(context).appState.syncStatus == SyncStatus.Done ? 0.1 : 1.0,
          duration: Duration(milliseconds: 1000),
          child: SyncButton()
        ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          showSearch(
            context: context,
            delegate: NoteSearchDelegate(
              sortedNotesFolder.notes,
              _viewType,
            ),
          );
        },
      )
    ];
  }

  List<Widget> _buildInSelectionNoteActions() {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: () async {
          await shareNote(selectedNote);
          _resetSelection();
        },
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: _deleteNote,
      ),
    ];
  }

  void _deleteNote() async {
    var note = selectedNote;

    var shouldDelete = await showDialog(
      context: context,
      builder: (context) => NoteDeleteDialog(),
    );
    if (shouldDelete == true) {
      var stateContainer = Provider.of<StateContainer>(context, listen: false);
      stateContainer.removeNote(note);
    }

    _resetSelection();
  }

  void _resetSelection() {
    setState(() {
      selectedNote = null;
      inSelectionMode = false;
    });
  }
}

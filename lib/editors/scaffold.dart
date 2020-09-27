import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:provider/provider.dart';

import 'package:simplewave/core/note.dart';
import 'package:simplewave/core/notes_folder_fs.dart';
import 'package:simplewave/editors/common.dart';
import 'package:simplewave/settings.dart';
import 'package:simplewave/widgets/note_viewer.dart';

class EditorScaffold extends StatefulWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final bool editMode;
  final IconButton extraButton;
  final Widget body;
  final NotesFolderFS parentFolder;

  EditorScaffold({
    @required this.editor,
    @required this.editorState,
    @required this.noteModified,
    @required this.editMode,
    @required this.body,
    @required this.parentFolder,
    this.extraButton,
  });

  @override
  _EditorScaffoldState createState() => _EditorScaffoldState();
}

class _EditorScaffoldState extends State<EditorScaffold> {
  var hideUIElements = false;
  var editingMode = true;
  Note note;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance
        .addPostFrameCallback((_) => _initStateWithContext());
  }

  void _initStateWithContext() {
    if (!mounted) return;

    var settings = Provider.of<Settings>(context, listen: false);

    setState(() {
      hideUIElements = settings.zenMode;
      widget.editorState.addListener(_editorChanged);

      editingMode = settings.markdownDefaultView == SettingsMarkdownDefaultView.Edit;

      if (widget.editMode) {
        editingMode = true;
      }

      note = widget.editorState.getNote();
    });
  }

  @override
  void dispose() {
    widget.editorState.removeListener(_editorChanged);

    super.dispose();
  }

  void _editorChanged() {
    var settings = Provider.of<Settings>(context, listen: false);

    if (settings.zenMode && !hideUIElements) {
      setState(() {
        hideUIElements = true;
      });
    }
  }

  void _switchMode() {
    var settings = Provider.of<Settings>(context, listen: false);

    setState(() {
      editingMode = !editingMode;
      settings.save();
      note = widget.editorState.getNote();
    });
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);
    Widget body = editingMode
        ? widget.body
        : NoteViewer(
            note: note,
            parentFolder: widget.parentFolder,
          );

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (hideUIElements == true) {
            setState(() {
              hideUIElements = false;
            });
          }
        },
        onDoubleTap: () {
          if (hideUIElements == false) {
            setState(() {
              hideUIElements = true;
            });
          } else {
            setState(() {
              hideUIElements = false;
            });
          }
        },
        child: Column(
          children: <Widget>[
            _AnimatedOpacityIgnorePointer(
              visible: !hideUIElements,
              child: EditorAppBar(
                editor: widget.editor,
                editorState: widget.editorState,
                noteModified: widget.noteModified,
                extraButton: widget.extraButton,
                allowEdits: editingMode,
                onEditingModeChange: _switchMode,
              ),
            ),
            Expanded(child: body),
            _AnimatedOpacityIgnorePointer(
              visible: !hideUIElements,
              child: EditorBottomBar(
                editor: widget.editor,
                editorState: widget.editorState,
                parentFolder: widget.parentFolder,
                allowEdits: editingMode,
                zenMode: settings.zenMode,
                onZenModeChanged: () {
                  setState(() {
                    settings.zenMode = !settings.zenMode;
                    settings.save();

                    if (settings.zenMode) {
                      hideUIElements = true;
                    }
                  });
                },
                metaDataEditable: note != null ? note.canHaveMetadata : false,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AnimatedOpacityIgnorePointer extends StatelessWidget {
  final bool visible;
  final Widget child;

  _AnimatedOpacityIgnorePointer({@required this.visible, @required this.child});

  @override
  Widget build(BuildContext context) {
    var opacity = visible ? 1.0 : 0.0;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: opacity,
        child: child,
      ),
    );
  }
}

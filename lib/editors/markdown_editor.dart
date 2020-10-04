import 'dart:io';

import 'package:flutter/material.dart';

import 'package:simplewave/core/note.dart';
import 'package:simplewave/core/notes_folder.dart';
import 'package:simplewave/editors/common.dart';
import 'package:simplewave/editors/disposable_change_notifier.dart';
import 'package:simplewave/editors/heuristics.dart';
import 'package:simplewave/editors/note_body_editor.dart';
import 'package:simplewave/editors/note_title_editor.dart';
import 'package:simplewave/error_reporting.dart';
import 'package:simplewave/utils/logger.dart';
import 'package:simplewave/widgets/editor_scroll_view.dart';

class MarkdownEditor extends StatefulWidget implements Editor {
  final Note note;
  final NotesFolder parentFolder;
  final bool noteModified;

  @override
  final NoteCallback noteDeletionSelected;
  @override
  final NoteCallback exitEditorSelected;
  @override
  final NoteCallback renameNoteSelected;
  @override
  final NoteCallback editTagsSelected;
  @override
  final NoteCallback moveNoteToFolderSelected;
  @override
  final NoteCallback discardChangesSelected;

  final bool editMode;

  MarkdownEditor({
    Key key,
    @required this.note,
    @required this.parentFolder,
    @required this.noteModified,
    @required this.noteDeletionSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.editTagsSelected,
    @required this.moveNoteToFolderSelected,
    @required this.discardChangesSelected,
    @required this.editMode,
  }) : super(key: key);

  @override
  MarkdownEditorState createState() {
    return MarkdownEditorState(note);
  }
}

class MarkdownEditorState extends State<MarkdownEditor>
    with DisposableChangeNotifier
    implements EditorState {
  Note note;
  TextEditingController _textController = TextEditingController();
  TextEditingController _titleTextController = TextEditingController();

  String _oldText;

  bool _noteModified;

  MarkdownEditorState(this.note) {
    _textController = TextEditingController(text: note.body);
    _titleTextController = TextEditingController(text: note.title);
    _oldText = note.body;
  }

  @override
  void initState() {
    super.initState();
    _noteModified = widget.noteModified;
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleTextController.dispose();

    super.disposeListenables();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.noteModified != widget.noteModified) {
      _noteModified = widget.noteModified;
    }
  }

  @override
  Widget build(BuildContext context) {
    var editor = EditorScrollView(
      child: Column(
        children: <Widget>[
          NoteTitleEditor(
            _titleTextController,
            _noteTextChanged,
          ),
          NoteBodyEditor(
            textController: _textController,
            autofocus: widget.editMode,
            onChanged: _noteTextChanged,
          ),
        ],
      ),
    );

    /*

    var settings = Provider.of<Settings>(context);
    if (settings.experimentalMarkdownToolbar && editingMode) {
      body = Container(
        child: Column(
          children: <Widget>[
            Expanded(child: editor),
            MarkdownToolBar(
              textController: _textController,
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      );
    }
    */

    return EditorScaffold(
      editor: widget,
      editorState: this,
      noteModified: _noteModified,
      editMode: widget.editMode,
      parentFolder: note.parent,
      body: editor,
    );
  }

  void _updateNote() {
    note.title = _titleTextController.text.trim();
    note.body = _textController.text.trim();
    note.type = NoteType.Unknown;
  }

  @override
  Note getNote() {
    _updateNote();
    return note;
  }

  void _noteTextChanged() {
    try {
      _applyHeuristics();
    } catch (e, stackTrace) {
      Log.e("EditorHeuristics: $e");
      logExceptionWarning(e, stackTrace);
    }
    if (_noteModified && !widget.editMode) return;

    var newState = !(widget.editMode && _textController.text.trim().isEmpty);
    if (newState != _noteModified) {
      setState(() {
        _noteModified = newState;
      });
    }

    notifyListeners();
  }

  void _applyHeuristics() {
    var selection = _textController.selection;
    if (selection.baseOffset != selection.extentOffset) {
      _oldText = _textController.text;
      return;
    }

    var r =
        autoAddBulletList(_oldText, _textController.text, selection.baseOffset);
    _oldText = _textController.text;

    if (r == null) {
      return;
    }

    _textController.text = r.text;
    _textController.selection = TextSelection.collapsed(offset: r.cursorPos);
  }

  @override
  Future<void> addImage(File file) async {
    await getNote().addImage(file);
    setState(() {
      _textController.text = note.body;
      _noteModified = true;
    });
  }

  @override
  bool get noteModified => _noteModified;
}

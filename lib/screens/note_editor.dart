import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notium/core/md_yaml_doc.dart';
import 'package:notium/core/note.dart';
import 'package:notium/core/notes_folder.dart';
import 'package:notium/core/notes_folder_fs.dart';
import 'package:notium/editors/checklist_editor.dart';
import 'package:notium/editors/markdown_editor.dart';
import 'package:notium/error_reporting.dart';
import 'package:notium/state_container.dart';
import 'package:notium/utils.dart';
import 'package:notium/utils/logger.dart';
import 'package:notium/widgets/folder_selection_dialog.dart';
import 'package:notium/widgets/note_delete_dialog.dart';
import 'package:notium/widgets/rename_dialog.dart';
import 'package:provider/provider.dart';

class ShowUndoSnackbar {}

class NoteEditor extends StatefulWidget {
  final Note note;
  final NotesFolderFS notesFolder;
  final NotesFolder parentFolderView;
  final EditorType defaultEditorType;

  final String existingText;
  final List<String> existingImages;

  final Map<String, dynamic> newNoteExtraProps;
  final bool editMode;

  NoteEditor.fromNote(
    this.note,
    this.parentFolderView, {
    this.editMode = false,
  })  : notesFolder = note.parent,
        defaultEditorType = null,
        existingText = null,
        existingImages = null,
        newNoteExtraProps = null;

  NoteEditor.newNote(
    this.notesFolder,
    this.parentFolderView,
    this.defaultEditorType, {
    this.existingText,
    this.existingImages,
    this.newNoteExtraProps = const {},
  })  : note = null,
        editMode = true;

  @override
  NoteEditorState createState() {
    if (note == null) {
      return NoteEditorState.newNote(
        notesFolder,
        existingText,
        existingImages,
        newNoteExtraProps,
      );
    } else {
      return NoteEditorState.fromNote(note);
    }
  }
}

enum EditorType { Markdown, Checklist }

class NoteEditorState extends State<NoteEditor> with WidgetsBindingObserver {
  Note note;
  EditorType editorType = EditorType.Markdown;
  MdYamlDoc originalNoteData = MdYamlDoc();

  final _markdownEditorKey = GlobalKey<MarkdownEditorState>();
  final _checklistEditorKey = GlobalKey<ChecklistEditorState>();

  bool get _isNewNote {
    return widget.note == null;
  }

  NoteEditorState.newNote(
    NotesFolderFS folder,
    String existingText,
    List<String> existingImages,
    Map<String, dynamic> extraProps,
  ) {
    note = Note.newNote(folder, extraProps: extraProps);
    if (existingText != null) {
      note.body = existingText;
    }

    if (existingImages != null) {
      for (var imagePath in existingImages) {
        try {
          var file = File(imagePath);
          note.addImageSync(file);
        } catch (e) {
          Log.e(e);
        }
      }
    }
  }

  NoteEditorState.fromNote(this.note) {
    originalNoteData = MdYamlDoc.from(note.data);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.defaultEditorType != null) {
      editorType = widget.defaultEditorType;
    } else {
      switch (note.type) {
        case NoteType.Checklist:
          editorType = EditorType.Checklist;
          break;
        case NoteType.Unknown:
          editorType = widget.notesFolder.config.defaultEditor;
          break;
      }
    }

    // Txt files
    if (note.fileFormat == NoteFileFormat.Txt &&
        editorType == EditorType.Markdown) {
      editorType = EditorType.Markdown;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.i("Note Edit State: $state");
    if (state != AppLifecycleState.resumed) {
      var note = _getNoteFromEditor();
      if (!_noteModified(note)) return;

      Log.d("App Lost Focus - saving note");
      note.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var savedNote = await _saveNote(_getNoteFromEditor());
        return savedNote;
      },
      child: _getEditor(),
    );
  }

  Widget _getEditor() {
    switch (editorType) {
      case EditorType.Markdown:
        return MarkdownEditor(
          key: _markdownEditorKey,
          note: note,
          parentFolder: widget.parentFolderView,
          noteModified: _noteModified(note),
          noteDeletionSelected: _noteDeletionSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          editMode: widget.editMode
        );
      case EditorType.Checklist:
        return ChecklistEditor(
          key: _checklistEditorKey,
          note: note,
          noteModified: _noteModified(note),
          noteDeletionSelected: _noteDeletionSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          editMode: widget.editMode
        );
    }
    return null;
  }

  void _exitEditorSelected(Note note) async {
    var saved = await _saveNote(note);
    if (saved) {
      Navigator.pop(context);
    }
  }

  void _renameNoteSelected(Note _note) async {
    var fileName = await showDialog(
      context: context,
      builder: (_) => RenameDialog(
        oldPath: note.filePath,
        inputDecoration: tr('widgets.NoteEditor.fileName'),
        dialogTitle: tr('widgets.NoteEditor.renameFile'),
      ),
    );
    if (fileName is String) {
      if (_isNewNote) {
        setState(() {
          note = _note;
          note.rename(fileName);
        });
        return;
      }
      var container = Provider.of<StateContainer>(context, listen: false);
      container.renameNote(note, fileName);
    }
  }

  void _noteDeletionSelected(Note note) async {
    if (_isNewNote && !_noteModified(note)) {
      Navigator.pop(context);
      return;
    }

    var shouldDelete = await showDialog(
      context: context,
      builder: (context) => NoteDeleteDialog(),
    );
    if (shouldDelete == true) {
      _deleteNote(note);

      if (_isNewNote) {
        Navigator.pop(context); // Note Editor
      } else {
        Navigator.pop(context, ShowUndoSnackbar()); // Note Editor
      }
    }
  }

  void _deleteNote(Note note) {
    if (_isNewNote) {
      return;
    }

    var stateContainer = Provider.of<StateContainer>(context, listen: false);
    stateContainer.removeNote(note);
  }

  bool _noteModified(Note note) {
    if (_isNewNote) {
      return note.title.isNotEmpty || note.body.isNotEmpty;
    }

    if (note.data != originalNoteData) {
      var newSimplified = MdYamlDoc.from(note.data);
      newSimplified.props.remove(note.noteSerializer.settings.modifiedKey);
      newSimplified.body = newSimplified.body.trim();

      var originalSimplified = MdYamlDoc.from(originalNoteData);
      originalSimplified.props.remove(note.noteSerializer.settings.modifiedKey);
      originalSimplified.body = originalSimplified.body.trim();

      bool hasBeenModified = newSimplified != originalSimplified;
      if (hasBeenModified) {
        Log.d("Note modified");
        Log.d("Original: $originalSimplified");
        Log.d("New: $newSimplified");
        return true;
      }
    }
    return false;
  }

  // Returns bool indicating if the note was successfully saved
  Future<bool> _saveNote(Note note) async {
    if (!_noteModified(note)) return true;

    Log.d("Note modified - saving");
    try {
      var stateContainer = Provider.of<StateContainer>(context, listen: false);
      _isNewNote
          ? await stateContainer.addNote(note)
          : await stateContainer.updateNote(note);
    } catch (e, stackTrace) {
      logException(e, stackTrace);
      Clipboard.setData(ClipboardData(text: note.serialize()));

      await showAlertDialog(
        context,
        tr("editors.common.saveNoteFailed.title"),
        tr("editors.common.saveNoteFailed.message"),
      );
      return false;
    }

    return true;
  }

  Note _getNoteFromEditor() {
    switch (editorType) {
      case EditorType.Markdown:
        return _markdownEditorKey.currentState.getNote();
      case EditorType.Checklist:
        return _checklistEditorKey.currentState.getNote();
    }
    return null;
  }

  void _moveNoteToFolderSelected(Note note) async {
    var destFolder = await showDialog<NotesFolderFS>(
      context: context,
      builder: (context) => FolderSelectionDialog(),
    );
    if (destFolder != null) {
      if (_isNewNote) {
        note.parent = destFolder;
        setState(() {});
      } else {
        var stateContainer =
            Provider.of<StateContainer>(context, listen: false);
        stateContainer.moveNote(note, destFolder);
      }
    }
  }

  void _discardChangesSelected(Note note) async {
    var stateContainer = Provider.of<StateContainer>(context, listen: false);
    stateContainer.discardChanges(note);

    Navigator.pop(context);
  }
}

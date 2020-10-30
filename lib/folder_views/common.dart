import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:notium/core/note.dart';
import 'package:notium/core/notes_folder.dart';
import 'package:notium/folder_views/grid_view.dart';
import 'package:notium/screens/note_editor.dart';
import 'package:notium/repository.dart';
import 'package:notium/utils.dart';
import 'package:notium/utils/logger.dart';
import 'standard_view.dart';

enum FolderViewType {
  Grid,
}

Widget buildFolderView({
  @required FolderViewType viewType,
  @required NotesFolder folder,
  @required String emptyText,
  @required StandardViewHeader header,
  @required bool showSummary,
  @required NoteSelectedFunction noteTapped,
  @required NoteSelectedFunction noteLongPressed,
  @required NoteBoolPropertyFunction isNoteSelected,
  @required String searchTerm,
  }) {
  return GridFolderView(
    folder: folder,
    noteTapped: noteTapped,
    noteLongPressed: noteLongPressed,
    emptyText: emptyText,
    isNoteSelected: isNoteSelected,
    searchTerm: searchTerm,
  );
}

void openNoteEditor(
  BuildContext context,
  Note note,
  NotesFolder parentFolder, {
  bool editMode = false,
}) async {
  var route = MaterialPageRoute(
    builder: (context) => NoteEditor.fromNote(note, parentFolder, editMode: editMode),
    settings: const RouteSettings(name: '/note/'),
  );
  var showUndoSnackBar = await Navigator.of(context).push(route);
  if (showUndoSnackBar != null) {
    Log.d("Showing an undo snackbar");

    var stateContainer = Provider.of<Repository>(context, listen: false);
    var snackBar = buildUndoDeleteSnackbar(stateContainer, note);
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

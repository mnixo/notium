import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:simplewave/core/note.dart';
import 'package:simplewave/core/notes_folder.dart';
import 'package:simplewave/folder_views/card_view.dart';
import 'package:simplewave/folder_views/grid_view.dart';
import 'package:simplewave/folder_views/journal_view.dart';
import 'package:simplewave/screens/note_editor.dart';
import 'package:simplewave/state_container.dart';
import 'package:simplewave/utils.dart';
import 'package:simplewave/utils/logger.dart';
import 'standard_view.dart';

enum FolderViewType {
  Standard,
  Journal,
  Card,
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
  switch (viewType) {
    case FolderViewType.Standard:
      return StandardView(
        folder: folder,
        noteTapped: noteTapped,
        noteLongPressed: noteLongPressed,
        emptyText: emptyText,
        headerType: header,
        showSummary: showSummary,
        isNoteSelected: isNoteSelected,
        searchTerm: searchTerm,
      );
    case FolderViewType.Journal:
      return JournalView(
        folder: folder,
        noteTapped: noteTapped,
        noteLongPressed: noteLongPressed,
        emptyText: emptyText,
        isNoteSelected: isNoteSelected,
        searchTerm: searchTerm,
      );
    case FolderViewType.Card:
      return CardView(
        folder: folder,
        noteTapped: noteTapped,
        noteLongPressed: noteLongPressed,
        emptyText: emptyText,
        isNoteSelected: isNoteSelected,
        searchTerm: searchTerm,
      );
    case FolderViewType.Grid:
      return GridFolderView(
        folder: folder,
        noteTapped: noteTapped,
        noteLongPressed: noteLongPressed,
        emptyText: emptyText,
        isNoteSelected: isNoteSelected,
        searchTerm: searchTerm,
      );
  }

  assert(false, "Code path should never be executed");
  return Container();
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

    var stateContainer = Provider.of<StateContainer>(context, listen: false);
    var snackBar = buildUndoDeleteSnackbar(stateContainer, note);
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

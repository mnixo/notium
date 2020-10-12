import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:notium/core/note.dart';
import 'package:notium/core/notes_folder_fs.dart';
import 'package:notium/core/sorted_notes_folder.dart';
import 'package:notium/core/sorting_mode.dart';

void main() {
  group('Sorted Notes Folder Test', () {
    Directory tempDir;
    NotesFolderFS folder;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('__sorted_folder_test__');

      folder = NotesFolderFS(null, tempDir.path);

      var random = Random();
      for (var i = 0; i < 5; i++) {
        var note = Note(
          folder,
          p.join(folder.folderPath, "${random.nextInt(1000)}.md"),
        );
        note.modified = DateTime(2020, 1, 10 + (i * 2));
        note.body = "$i";
        await note.save();
      }
      await folder.loadRecursively();
    });

    tearDown(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should load the notes sorted', () async {
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );
      expect(sf.hasNotes, true);
      expect(sf.isEmpty, false);
      expect(sf.name.startsWith("__sorted_folder_test__"), true);
      expect(sf.subFolders.length, 0);
      expect(sf.notes.length, 5);

      expect(sf.notes[0].body, "4");
      expect(sf.notes[1].body, "3");
      expect(sf.notes[2].body, "2");
      expect(sf.notes[3].body, "1");
      expect(sf.notes[4].body, "0");
    });

    test('Should on modification remains sorted', () async {
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );

      var i = sf.notes.indexWhere((n) => n.body == "1");
      sf.notes[i].modified = DateTime(2020, 2, 1);

      expect(sf.notes[0].body, "1");
      expect(sf.notes[1].body, "4");
      expect(sf.notes[2].body, "3");
      expect(sf.notes[3].body, "2");
      expect(sf.notes[4].body, "0");
    });

    test('Should add new note correctly', () async {
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );

      var note = Note(folder, p.join(folder.folderPath, "new.md"));
      note.modified = DateTime(2020, 2, 1);
      note.body = "new";
      await note.save();

      folder.add(note);

      expect(sf.notes.length, 6);

      expect(sf.notes[0].body, "new");
      expect(sf.notes[1].body, "4");
      expect(sf.notes[2].body, "3");
      expect(sf.notes[3].body, "2");
      expect(sf.notes[4].body, "1");
      expect(sf.notes[5].body, "0");
    });

    test('Should add new note to end works correctly', () async {
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );

      var note = Note(folder, p.join(folder.folderPath, "new.md"));
      note.modified = DateTime(2020, 1, 1);
      note.body = "new";
      await note.save();

      folder.add(note);

      expect(sf.notes.length, 6);

      expect(sf.notes[0].body, "4");
      expect(sf.notes[1].body, "3");
      expect(sf.notes[2].body, "2");
      expect(sf.notes[3].body, "1");
      expect(sf.notes[4].body, "0");
      expect(sf.notes[5].body, "new");
    });

    test('If still sorted while loading the notes', () async {
      var folder = NotesFolderFS(null, tempDir.path);
      var sf = SortedNotesFolder(
        folder: folder,
        sortingMode:
            SortingMode(SortingField.Modified, SortingOrder.Descending),
      );

      await folder.loadRecursively();

      expect(sf.hasNotes, true);
      expect(sf.isEmpty, false);
      expect(sf.name.startsWith("__sorted_folder_test__"), true);
      expect(sf.subFolders.length, 0);
      expect(sf.notes.length, 5);

      expect(sf.notes[0].body, "4");
      expect(sf.notes[1].body, "3");
      expect(sf.notes[2].body, "2");
      expect(sf.notes[3].body, "1");
      expect(sf.notes[4].body, "0");
    });
  });
}

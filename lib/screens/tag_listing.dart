import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:simplewave/core/flattened_notes_folder.dart';
import 'package:simplewave/core/note.dart';
import 'package:simplewave/core/note_serializer.dart';
import 'package:simplewave/core/notes_folder_fs.dart';
import 'package:simplewave/features.dart';
import 'package:simplewave/screens/folder_view.dart';
import 'package:simplewave/widgets/app_bar_menu_button.dart';
import 'package:simplewave/widgets/app_drawer.dart';
import 'package:simplewave/widgets/pro_overlay.dart';

class TagListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var rootFolder = Provider.of<NotesFolderFS>(context);
    var allTags = rootFolder.getNoteTagsRecursively();
    var allTagsSorted = SplayTreeSet<String>.from(allTags);

    Widget body;
    if (allTagsSorted.isNotEmpty) {
      body = ListView(
        children: <Widget>[
          for (var tag in allTagsSorted) _buildTagTile(context, tag),
        ],
      );
    } else {
      body = Center(
        child: Text(
          tr("screens.tags.empty"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[350],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('screens.tags.title')),
        leading: GJAppBarMenuButton(),
      ),
      body: Scrollbar(
        child: ProOverlay(
          feature: Feature.tags,
          child: body,
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  Widget _buildTagTile(BuildContext context, String tag) {
    var theme = Theme.of(context);
    var titleColor = theme.textTheme.headline1.color;

    return ListTile(
      leading: FaIcon(FontAwesomeIcons.tag, color: titleColor),
      title: Text(tag),
      onTap: () {
        var route = MaterialPageRoute(
          builder: (context) {
            var rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
            var folder = FlattenedNotesFolder(
              rootFolder,
              filter: (Note n) =>
                  n.tags.contains(tag) || n.inlineTags.contains(tag),
              title: tag,
            );

            final propNames = NoteSerializationSettings();
            return FolderView(
              notesFolder: folder,
              newNoteExtraProps: {
                propNames.tagsKey: [tag],
              },
            );
          },
          settings: const RouteSettings(name: '/tags/'),
        );
        Navigator.of(context).push(route);
      },
    );
  }
}

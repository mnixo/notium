import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';

import 'package:notium/screens/note_editor.dart';

class NewNoteNavBar extends StatelessWidget {
  final Func1<EditorType, void> onPressed;

  NewNoteNavBar({@required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).bottomAppBarColor,
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0,4.0,100.0,4.0),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.tasks),
              onPressed: () => onPressed(EditorType.Checklist),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}

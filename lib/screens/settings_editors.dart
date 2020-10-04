import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:simplewave/screens/settings_widgets.dart';
import 'package:simplewave/settings.dart';

class SettingsEditorsScreen extends StatefulWidget {
  @override
  SettingsEditorsScreenState createState() => SettingsEditorsScreenState();
}

class SettingsEditorsScreenState extends State<SettingsEditorsScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

    var body = ListView(children: <Widget>[
      ListPreference(
        title: tr("settings.editors.defaultEditor"),
        currentOption: settings.defaultEditor.toPublicString(),
        options:
            SettingsEditorType.options.map((f) => f.toPublicString()).toList(),
        onChange: (String publicStr) {
          var val = SettingsEditorType.fromPublicString(publicStr);
          settings.defaultEditor = val;
          settings.save();
          setState(() {});
        },
      ),
      //SettingsHeader(tr("settings.editors.markdownEditor")),
      ListPreference(
        title: tr("settings.editors.defaultState"),
        currentOption: settings.markdownDefaultView.toPublicString(),
        options: SettingsMarkdownDefaultView.options
            .map((f) => f.toPublicString())
            .toList(),
        onChange: (String publicStr) {
          var val = SettingsMarkdownDefaultView.fromPublicString(publicStr);
          settings.markdownDefaultView = val;
          settings.save();
          setState(() {});
        },
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.editors.title")),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
    );
  }
}

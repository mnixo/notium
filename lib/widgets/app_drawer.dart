import 'dart:io';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:simplewave/analytics.dart';
import 'package:simplewave/app_settings.dart';
import 'package:simplewave/settings.dart';
import 'package:simplewave/utils.dart';
import 'package:simplewave/utils/logger.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget setupGitButton;
    var settings = Provider.of<Settings>(context);
    var appSettings = Provider.of<AppSettings>(context);
    var textStyle = Theme.of(context).textTheme.bodyText1;
    var currentRoute = ModalRoute.of(context).settings.name;

    if (!settings.remoteGitRepoConfigured) {
      setupGitButton = ListTile(
        leading: Icon(Icons.sync, color: textStyle.color),
        title: Text(tr('drawer.setup'), style: textStyle),
        trailing: const Icon(
          Icons.info,
          color: Colors.red,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, "/setupRemoteGit");

          logEvent(Event.DrawerSetupGitHost);
        },
      );
    }

    var divider = Row(children: <Widget>[const Expanded(child: Divider())]);

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          _AppDrawerHeader(),
          if (setupGitButton != null) ...[setupGitButton, divider],
          _buildDrawerTile(
            context,
            icon: Icons.note,
            title: tr('drawer.all'),
            onTap: () => _navTopLevel(context, '/'),
            selected: currentRoute == '/',
          ),
          _buildDrawerTile(
            context,
            icon: Icons.folder,
            title: tr('drawer.folders'),
            onTap: () => _navTopLevel(context, '/folders'),
            selected: currentRoute == "/folders",
          ),
          _buildDrawerTile(
            context,
            icon: FontAwesomeIcons.tag,
            isFontAwesome: true,
            title: tr('drawer.tags'),
            onTap: () => _navTopLevel(context, '/tags'),
            selected: currentRoute == "/tags",
          ),
          divider,
          _buildDrawerTile(
            context,
            icon: Icons.bug_report,
            title: tr('drawer.bug'),
            onTap: () async {
              var platform = Platform.operatingSystem;
              var versionText = await getVersionString();
              var appLogsFilePath = Log.filePathForDate(DateTime.now());

              final Email email = Email(
                body:
                    "Hey!\n\nI found a bug in simplewave - \n \n\nVersion: $versionText\nPlatform: $platform",
                subject: 'simplewave bug report',
                recipients: ['simplewave.app+bugs@gmail.com'],
                attachmentPaths: [appLogsFilePath],
              );

              await FlutterEmailSender.send(email);

              Navigator.pop(context);
              logEvent(Event.DrawerBugReport);
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.settings,
            title: tr('settings.title'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/settings");

              logEvent(Event.DrawerSettings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    @required IconData icon,
    @required String title,
    @required Function onTap,
    bool isFontAwesome = false,
    bool selected = false,
  }) {
    var theme = Theme.of(context);
    var listTileTheme = ListTileTheme.of(context);
    var textStyle = theme.textTheme.bodyText1.copyWith(
      color: selected ? theme.focusColor : listTileTheme.textColor,
    );

    var iconW = !isFontAwesome
        ? Icon(icon, color: textStyle.color)
        : FaIcon(icon, color: textStyle.color);

    var tile = ListTile(
      leading: iconW,
      title: Text(title, style: textStyle),
      onTap: onTap,
      selected: selected,
    );
    return Container(
      child: tile,
      color: selected ? theme.selectedRowColor : theme.scaffoldBackgroundColor,
    );
  }
}

void _navTopLevel(BuildContext context, String toRoute) {
  var fromRoute = ModalRoute.of(context).settings.name;
  Log.i("Routing from $fromRoute -> $toRoute");

  // Always first pop the AppBar
  Navigator.pop(context);

  if (fromRoute == toRoute) {
    return;
  }

  var wasParent = false;
  Navigator.popUntil(
    context,
    (route) {
      if (route.isFirst) {
        return true;
      }
      wasParent = route.settings.name == toRoute;
      if (wasParent) {
        Log.i("Router popping ${route.settings.name}");
      }
      return wasParent;
    },
  );
  if (!wasParent) {
    Navigator.pushNamed(context, toRoute);
  }
}

class _AppDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);

    return Stack(
      children: <Widget>[
        Container(
        height: 80.0,
          child:DrawerHeader(
            margin: const EdgeInsets.all(0.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Padding(
              padding: EdgeInsets.zero,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icon/icon.png'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      fit: StackFit.passthrough,
    );
  }
}


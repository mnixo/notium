import 'dart:async';

import 'package:badges/badges.dart';
import 'package:connectivity/connectivity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:notium/repository.dart';
import 'package:notium/utils.dart';
import 'package:provider/provider.dart';

class SyncButton extends StatefulWidget {
  @override
  _SyncButtonState createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  StreamSubscription<ConnectivityResult> subscription;
  ConnectivityResult _connectivity;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _connectivity = result;
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<Repository>(context);

    if (_connectivity == ConnectivityResult.none) {
      return GitPendingChangesBadge(
        child: IconButton(
          icon: const Icon(Icons.signal_wifi_off),
          onPressed: () async {
            _syncRepo();
          },
        ),
      );
    }
    if (repo.syncStatus == SyncStatus.Pulling) {
      return GitPendingChangesBadge(
        child: IconButton(
          icon: const Icon(Icons.cloud_download),
          onPressed: () {},
        ),
      );
    }

    if (repo.syncStatus == SyncStatus.Pushing) {
      return GitPendingChangesBadge(
        child: IconButton(
          icon: const Icon(Icons.cloud_upload),
          onPressed: () {},
        ),
      );
    }

    return GitPendingChangesBadge(
      child: IconButton(
        icon: Icon(_syncStatusIcon()),
        onPressed: () async {
          _syncRepo();
        },
      ),
    );
  }

  void _syncRepo() async {
    try {
      final container = Provider.of<Repository>(context, listen: false);
      await container.syncNotes();
    } on GitException catch (e) {
      showSnackbar(context, tr('widgets.SyncButton.error', args: [e.cause]));
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  IconData _syncStatusIcon() {
    final repo = Provider.of<Repository>(context);
    switch (repo.syncStatus) {
      case SyncStatus.Error:
        return Icons.cloud_off;

      case SyncStatus.Unknown:
      case SyncStatus.Done:
      default:
        return Icons.cloud_done;
    }
  }
}

class GitPendingChangesBadge extends StatelessWidget {
  final Widget child;

  GitPendingChangesBadge({@required this.child});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var darkMode = theme.brightness == Brightness.dark;
    var style = theme.textTheme.caption.copyWith(
      fontSize: 8.0,
      fontFamily: 'IBMPlexMono-Light',
      color: darkMode ? Colors.black : Colors.white,
    );

    final repo = Provider.of<Repository>(context);

    return Badge(
      badgeContent: Text(repo.numChanges.toString(), style: style),
      toAnimate: true,
      animationDuration: Duration(milliseconds: 1000),
      animationType: BadgeAnimationType.fade,
      showBadge: repo.numChanges != 0,
      badgeColor: theme.iconTheme.color,
      position: BadgePosition.topRight(top: 10.0, right: 4.0),
      child: child,
    );
  }
}

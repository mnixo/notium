import 'package:flutter/material.dart';

class GJAppBarMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appBarMenuButton = IconButton(
      key: const ValueKey("DrawerButton"),
      icon: Image.asset('assets/icon/icon-small.png'),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );

    return appBarMenuButton;
  }
}

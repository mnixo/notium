import 'package:flutter/material.dart';

class GJAppBarMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var assetToUse = "";
    var theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      assetToUse = 'assets/icon/icon.png';
    } else {
      assetToUse = 'assets/icon/icon_black.png';
    }

    var appBarMenuButton = IconButton(
      key: const ValueKey("DrawerButton"),
      icon: Image.asset(assetToUse),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );

    return appBarMenuButton;
  }
}

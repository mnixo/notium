import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:notium/utils/logger.dart';

class GitHostSetupButton extends StatelessWidget {
  final Func0<void> onPressed;
  final String text;
  final String iconUrl;

  GitHostSetupButton({
    @required this.text,
    @required this.onPressed,
    this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null) {
      return SizedBox(
        width: double.infinity,
        child: FlatButton(
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.button,
          ),
          color: Theme.of(context).buttonColor,
          onPressed: _onPressedWithLog,
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: FlatButton.icon(
          label: Text(
            text,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.button,
          ),
          icon: Image.asset(iconUrl, width: 32, height: 32),
          color: Theme.of(context).buttonColor,
          onPressed: _onPressedWithLog,
        ),
      );
    }
  }

  void _onPressedWithLog() {
    Log.d("githostsetup_button_click " + text);
    onPressed();
  }
}

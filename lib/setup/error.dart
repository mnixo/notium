import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class GitHostSetupErrorPage extends StatelessWidget {
  final String errorMessage;

  GitHostSetupErrorPage(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          tr("setup.fail"),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      if(errorMessage == "Invalid Credentials")
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
          child: Text(
            tr("setup.gitErrors.invalidCredentials"),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';
import 'package:git_url_parse2/git_url_parse2.dart';

import 'package:notium/apis/githost_factory.dart';
import 'button.dart';

class GitCloneUrlPage extends StatefulWidget {
  final Func1<String, void> doneFunction;
  final String initialValue;

  GitCloneUrlPage({
    @required this.doneFunction,
    @required this.initialValue,
  });

  @override
  GitCloneUrlPageState createState() {
    return GitCloneUrlPageState();
  }
}

class GitCloneUrlPageState extends State<GitCloneUrlPage> {
  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final formSubmitted = () {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        var url = sshUrlKey.currentState.value;
        widget.doneFunction(url.trim());
      }
    };

    var inputForm = Form(
      key: _formKey,

      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.left,
        autofocus: false,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: const InputDecoration(
          hintText: 'git@service.com:username/repo_name.git',
        ),
        validator: _isCloneUrlValid,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
        initialValue: widget.initialValue,
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0, 32, 0, 32),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tr("setup.cloneUrl.enter"),
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: inputForm,
          ),
          const SizedBox(height: 16.0),
          GitHostSetupButton(
            text: "Next",
            onPressed: formSubmitted,
          ),
        ],
      )
    );
  }
}

class GitCloneUrlKnownProviderPage extends StatefulWidget {
  final Func1<String, void> doneFunction;
  final Func0<void> launchCreateUrlPage;
  final GitHostType gitHostType;
  final String initialValue;

  GitCloneUrlKnownProviderPage({
    @required this.doneFunction,
    @required this.launchCreateUrlPage,
    @required this.gitHostType,
    @required this.initialValue,
  });

  @override
  GitCloneUrlKnownProviderPageState createState() {
    return GitCloneUrlKnownProviderPageState();
  }
}

class GitCloneUrlKnownProviderPageState
    extends State<GitCloneUrlKnownProviderPage> {
  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final formSubmitted = () {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        var url = sshUrlKey.currentState.value;
        widget.doneFunction(url.trim());
      }
    };

    var inputForm = Form(
      key: _formKey,
      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.left,
        autofocus: false,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: const InputDecoration(
          hintText: 'git@service.com:username/repo_name.git',
        ),
        validator: _isCloneUrlValid,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
        initialValue: widget.initialValue,
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
      child: Column(
        children: <Widget>[
          Text(
            tr("setup.cloneUrl.manual.description"),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 32.0),
          Text(
            tr("setup.cloneUrl.manual.createRepo"),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 16.0),
          GitHostSetupButton(
            text: tr("setup.cloneUrl.manual.button"),
            onPressed: widget.launchCreateUrlPage,
          ),
          const SizedBox(height: 16.0),

          // Step 2
          Text(
            tr("setup.cloneUrl.manual.step2"),
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 16.0),
          inputForm,
          const SizedBox(height: 16.0),
          GitHostSetupButton(
            text: tr("setup.next"),
            onPressed: formSubmitted,
          ),
        ],
      )
    );
  }
}

// Returns null when valid
String _isCloneUrlValid(String url) {
  url = url.trim();
  if (url.isEmpty) {
    return tr("setup.cloneUrl.validator.empty");
  }

  var result = gitUrlParse(url);
  if (result == null) {
    return tr("setup.cloneUrl.validator.invalid");
  }

  if (result.protocol != 'ssh') {
    return tr("setup.cloneUrl.validator.onlySsh");
  }

  return null;
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:notium/core/link.dart';
import 'package:notium/core/note.dart';
import 'package:notium/core/notes_folder.dart';
import 'package:notium/core/notes_folder_fs.dart';
import 'package:notium/folder_views/common.dart';
import 'package:notium/settings.dart';
import 'package:notium/utils.dart';
import 'package:notium/utils/link_resolver.dart';
import 'package:notium/utils/logger.dart';
import 'package:notium/widgets/editor_scroll_view.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteViewer extends StatelessWidget {
  final Note note;
  final NotesFolder parentFolder;
  const NoteViewer({
    Key key,
    @required this.note,
    @required this.parentFolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    theme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        subtitle1: theme.textTheme.subtitle1,
      ),
    );

    var isDark = theme.brightness == Brightness.dark;

    // Copied from MarkdownStyleSheet except Grey is replaced with Highlight color
    var markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      code: theme.textTheme.bodyText2.copyWith(
        backgroundColor: theme.dialogBackgroundColor,
        fontFamily: "monospace",
        fontSize: theme.textTheme.bodyText2.fontSize * 0.85,
      ),
      tableBorder: TableBorder.all(color: theme.highlightColor, width: 0),
      tableCellsDecoration: BoxDecoration(color: theme.dialogBackgroundColor),
      codeblockDecoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(2.0),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 3.0, color: theme.highlightColor),
        ),
      ),
      blockquoteDecoration: BoxDecoration(
        color: theme.primaryColorLight,
        borderRadius: BorderRadius.circular(2.0),
      ),
      checkbox: theme.textTheme.bodyText2.copyWith(
        color: isDark ? theme.primaryColorLight : theme.primaryColor,
      ),
    );

    final rootFolder = Provider.of<NotesFolderFS>(context);
    var view = EditorScrollView(
      child: Column(
        children: <Widget>[
          NoteTitleHeader(note.title),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: MarkdownBody(
              data: note.body,
              // selectable: false, -> making this true breaks link navigation
              styleSheet: markdownStyleSheet,
              onTapLink: (String link) async {
                final linkResolver = LinkResolver(note);

                var linkedNote = linkResolver.resolve(link);
                if (linkedNote != null) {
                  openNoteEditor(context, linkedNote, parentFolder);
                  return;
                }

                // External Link
                try {
                  await launch(link);
                } catch (e, stackTrace) {
                  Log.e("Opening Link", ex: e, stacktrace: stackTrace);
                  showSnackbar(
                    context,
                    tr('wigets.NoteViewer.linkNotFound', args: [link]),
                  );
                }
              },
              imageBuilder: (url, title, alt) => kDefaultImageBuilder(
                  url, note.parent.folderPath + p.separator, null, null),
              extensionSet: markdownExtensions(),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );

    return view;
  }

  static md.ExtensionSet markdownExtensions() {
    // It's important to add both these inline syntaxes before the other
    // syntaxes as the LinkSyntax intefers with both of these
    var markdownExtensions = md.ExtensionSet.gitHubFlavored;
    markdownExtensions.inlineSyntaxes.insert(0, WikiLinkSyntax());
    markdownExtensions.inlineSyntaxes.insert(1, TaskListSyntax());
    return markdownExtensions;
  }
}

class NoteTitleHeader extends StatelessWidget {
  final String header;
  NoteTitleHeader(this.header);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(header, style: textTheme.headline6),
    );
  }
}

//
// Copied from flutter_markdown
// But it uses CachedNetworkImage
//
typedef Widget ImageBuilder(
    Uri uri, String imageDirectory, double width, double height);

final ImageBuilder kDefaultImageBuilder = (
  Uri uri,
  String imageDirectory,
  double width,
  double height,
) {
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    return CachedNetworkImage(
      imageUrl: uri.toString(),
      width: width,
      height: height,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  } else if (uri.scheme == 'data') {
    return _handleDataSchemeUri(uri, width, height);
  } else if (uri.scheme == "resource") {
    return Image.asset(uri.path, width: width, height: height);
  } else {
    Uri fileUri = imageDirectory != null
        ? parseFileUri(imageDirectory, uri)
        : uri;
    if (fileUri.scheme == 'http' || fileUri.scheme == 'https') {
      return CachedNetworkImage(
        imageUrl: fileUri.toString(),
        width: width,
        height: height,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return Image.file(File.fromUri(fileUri), width: width, height: height);
    }
  }
};

Uri parseFileUri(String imageDirectory, Uri uri) {
  String imageKeyword = Settings.instance.imageKeyword;

  String rawUri = Uri.decodeFull(uri.toString());
  if(!rawUri.contains(imageKeyword)) {
    uri = Uri.parse(imageDirectory + uri.toString());
    return uri;
  }

  // image directory will be the subfolder where the note is located
  // => we need to get the root of the repo instead
  String basePath = p.absolute(imageDirectory);
  basePath = basePath.substring(
    0,
    basePath.indexOf(Settings.instance.folderName) + Settings.instance.folderName.length
  );
  // Now we replace the keyword with the actual path to the images folder
  rawUri = rawUri.replaceAll(imageKeyword, Settings.instance.imageLocationSpec);
  // And we join both, then make it a Uri
  // => Path to the image will work no matter where the note is located
  uri = Uri.parse(p.join(basePath, rawUri));
  return uri;
}

Widget _handleDataSchemeUri(Uri uri, final double width, final double height) {
  final String mimeType = uri.data.mimeType;
  if (mimeType.startsWith('image/')) {
    return Image.memory(
      uri.data.contentAsBytes(),
      width: width,
      height: height,
    );
  } else if (mimeType.startsWith('text/')) {
    return Text(uri.data.contentAsString());
  }
  return const SizedBox();
}

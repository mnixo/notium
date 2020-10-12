import 'package:markdown/markdown.dart' as md;
import 'package:test/test.dart';

import 'package:notium/widgets/note_viewer.dart';

void main() {
  test('Parses Wiki Lnks and task items', () {
    var body = "[[notium]] should match.\n- [ ] task item";
    var lines = body.split('\n');

    var doc = md.Document(
      encodeHtml: false,
      extensionSet: NoteViewer.markdownExtensions(),
      inlineSyntaxes: NoteViewer.markdownExtensions().inlineSyntaxes,
    );
    var nodes = doc.parseLines(lines);

    var expected =
        """<p><a type="wiki" href="[[notium]]" term="notium">notium</a> should match.</p>
<ul>
<li><input type="checkbox" disabled="true" checked="false"></input>task item</li>
</ul>""";

    expect(md.renderToHtml(nodes), expected);
  });

  test('Parses Piped Wiki Lnks', () {
    var body = "[[notium | fire]] should match.";
    var lines = body.split('\n');

    var doc = md.Document(
      encodeHtml: false,
      extensionSet: NoteViewer.markdownExtensions(),
      inlineSyntaxes: NoteViewer.markdownExtensions().inlineSyntaxes,
    );
    var nodes = doc.parseLines(lines);

    var expected =
        '<p><a type="wiki" href="[[notium]]" term="notium">fire</a> should match.</p>';

    expect(md.renderToHtml(nodes), expected);
  });
}

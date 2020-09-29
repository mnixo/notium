import 'package:test/test.dart';

import 'package:simplewave/core/links_loader.dart';

void main() {
  group('LinksLoader', () {
    var contents = """[[simplewave]]

[simplewave](./gitjournal.md)
[simplewave](gitjournal.md)
[simplewave](gitjournal "alt-text")

[Google](https://google.com)

[Google's Homepage][Google]

[Google]: https://www.google.com/
    """;

    test('Should load links', () async {
      var loader = LinksLoader();
      var links = await loader.parseLinks(
        body: contents,
        filePath: "/tmp/foo/file.md",
      );

      expect(links[0].filePath.isEmpty, true);
      expect(links[0].headingID.isEmpty, true);
      expect(links[0].alt.isEmpty, true);
      expect(links[0].publicTerm.isEmpty, true);
      expect(links[0].wikiTerm, "simplewave");
      expect(links[0].isWikiLink, true);

      expect(links[1].filePath, "/tmp/foo/gitjournal.md");
      expect(links[1].publicTerm, "simplewave");
      expect(links[1].alt.isEmpty, true);
      expect(links[1].wikiTerm.isEmpty, true);

      expect(links[2].filePath, "/tmp/foo/gitjournal.md");
      expect(links[2].publicTerm, "simplewave");
      expect(links[2].alt.isEmpty, true);
      expect(links[2].wikiTerm.isEmpty, true);

      expect(links[3].filePath, "/tmp/foo/gitjournal");
      expect(links[3].publicTerm, "simplewave");
      expect(links[3].alt, "alt-text");
      expect(links[3].wikiTerm.isEmpty, true);

      /*
      expect(links[4].filePath, "/tmp/foam.md");
      expect(links[4].publicTerm, "Foam");
      expect(links[4].alt, "foam");
      expect(links[4].wikiTerm.isEmpty, true);
      */

      expect(links.length, 4);
    });

    test('Foam Documentation', () async {
      var contents = """
[![All Contributors](https://img.shields.io/badge/all_contributors-38-orange.svg?style=flat-square)](#contributors-)

3. Use Foam's shortcuts and autocompletions to link your thoughts together with `[[wiki-links]]`, and navigate between them to explore your knowledge graph.
4. the [[Graph Visualisation](https://foambubble.github.io/foam/graph-visualisation)], of [[Backlinking](https://foambubble.github.io/foam/backlinking)].

![Foam kitchen sink, showing a few of the key features](docs/assets/images/foam-features-dark-mode-demo.png)

Foam is licensed under the [MIT license](license).

[//begin]: # "Autogenerated link references for markdown compatibility"
[wiki-links]: wiki-links "Wiki Links"
[//end]: # "Autogenerated link references"
""";

      var links = parseLinks(contents, "/tmp/foo.md");
      expect(links.length, 5);

      expect(links[0].filePath, "/tmp/foo.md");
      expect(links[0].alt.isEmpty, true);
      expect(links[0].headingID, "#contributors-");
      expect(links[0].publicTerm.isEmpty, true);

      expect(links[1].filePath, "/tmp/license");
      expect(links[1].alt.isEmpty, true);
      expect(links[1].headingID.isEmpty, true);
      expect(links[1].publicTerm, "MIT license");

      expect(links[2].filePath, "/tmp/foo.md");
      expect(links[2].publicTerm, '//begin');
      expect(links[2].headingID, "#");
      expect(links[2].alt,
          "Autogenerated link references for markdown compatibility");

      // FIXME: link-references for wiki Links
      // expect(links[3].filePath.isEmpty, true);
      // expect(links[3].isWikiLink, true);
      expect(links[3].headingID.isEmpty, true);
      expect(links[3].alt, "Wiki Links");

      expect(links[4].filePath, "/tmp/foo.md");
      expect(links[4].publicTerm, '//end');
      expect(links[4].headingID, "#");
      expect(links[4].alt, "Autogenerated link references");
    });
  });

  // Add a test for linking to a header in another Note
}

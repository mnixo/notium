import 'package:test/test.dart';

import 'package:simplewave/core/processors/wiki_links_auto_add.dart';

void main() {
  test('Should process body', () {
    var body =
        "simplewave is the best? And it works quite well with Foam, Foam and Obsidian.";

    var p = WikiLinksAutoAddProcessor(null);
    var newBody = p.processBody(body, ['simplewave', 'Foam', 'Obsidian']);
    var expectedBody =
        "[[simplewave]] is the best? And it works quite well with [[Foam]], [[Foam]] and [[Obsidian]].";

    expect(newBody, expectedBody);
  });

  // Add a test to see if processing a Note works
  // FIXME: Make sure the wiki link terms do not have special characters
  // FIXME: WHat about piped links?
}

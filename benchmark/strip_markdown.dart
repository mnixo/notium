// Import BenchmarkBase class.
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:notium/utils/markdown.dart';

// Create a new benchmark by extending BenchmarkBase
class StripMarkdownBenchmark extends BenchmarkBase {
  const StripMarkdownBenchmark() : super('StripMarkdown');

  static void main() {
    const StripMarkdownBenchmark().report();
  }

  // The benchmark code.
  @override
  void run() {
    var input = """Itemized lists
look like:

  * this one
  * that one
      """;

    stripMarkdownFormatting(input);
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {}

  // Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {}
}

void main() {
  // Run StripMarkdownBenchmark
  StripMarkdownBenchmark.main();
}

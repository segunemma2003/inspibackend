import 'package:nylo_framework/metro/ny_cli.dart';

void main(arguments) => _MotivationalQuoteCommand(arguments).run();

class _MotivationalQuoteCommand extends NyCustomCommand {
  _MotivationalQuoteCommand(super.arguments);

  @override
  CommandBuilder builder(CommandBuilder command) => command;

  @override
  Future<void> handle(CommandResult result) async {

    final responseName = prompt("Hello, what's your name?");
    if (responseName.isEmpty) {
      error('Please provide a valid name.');
      return;
    }

    final response = confirm('$responseName, would you like to get a motivational quote?');
    if (response == false) {
      print('No problem, have a great day!');
      return;
    }

    await withSpinner(
      task: () async {
        final List<dynamic>? data = await api((request) => request.get('https://zenquotes.io/api/today'));

        if (data == null || data.isEmpty) {
          error('\nNo data found');
          return;
        }

        print("\n");

        printQuote(
          quote: data[0]['q'],
          author: data[0]['a'],
        );

        print("\n");
      },
      message: 'Fetching motivational quote...',
      successMessage: 'Quote fetched successfully!',
      errorMessage: 'Failed to fetch quote.',
    );
  }
}

extension QuoteFormatter on NyCustomCommand {

  void printQuote({
    required String quote,
    required String author,
    String borderColor = '\x1B[36m', // Cyan
    String quoteColor = '\x1B[33m',   // Yellow
    String authorColor = '\x1B[35m',  // Magenta
    int maxWidth = 60,
  }) {

    final reset = '\x1B[0m';

    final wrappedQuote = _wrapText(quote, maxWidth - 4); // -4 for padding

    int width = 0;
    for (final line in wrappedQuote) {
      if (line.length > width) width = line.length;
    }

    width += 4; // 2 spaces on each side

    final authorText = '— $author '; // Note the space after author name

    if (width < authorText.length + 2) {
      width = authorText.length + 2;
    }

    final topBorder = '$borderColor╭${'─' * (width)}╮$reset';
    print(topBorder);

    final emptyLine = '$borderColor│${' ' * width}│$reset';
    print(emptyLine);

    for (final line in wrappedQuote) {

      final paddingRight = width - line.length - 2;
      final paddedLine = ' $line${' ' * paddingRight} ';

      print('$borderColor│$quoteColor$paddedLine$reset$borderColor│$reset');
    }

    print(emptyLine);

    final authorPadding = width - authorText.length;
    final authorLine = '$borderColor│${' ' * authorPadding}$authorColor$authorText$reset$borderColor│$reset';
    print(authorLine);

    final bottomBorder = '$borderColor╰${'─' * (width)}╯$reset';
    print(bottomBorder);
  }

  List<String> _wrapText(String text, int maxWidth) {
    final words = text.split(' ');
    final result = <String>[];
    String currentLine = '';

    for (final word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if (currentLine.length + word.length + 1 <= maxWidth) {
        currentLine += ' $word';
      } else {
        result.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      result.add(currentLine);
    }

    return result;
  }
}
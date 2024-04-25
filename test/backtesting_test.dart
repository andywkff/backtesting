import 'package:backtesting/backtesting.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final awesome = BTTrade();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesome.entryPrice, isNotNull);
    });
  });
}

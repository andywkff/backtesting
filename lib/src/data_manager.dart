import 'dart:collection';
import 'dart:math';

import 'package:csv/csv.dart';

import './model.dart';
import './util.dart';

/// Checks if you are awesome. Spoiler: you are.
class BTDataManager {
  // String toCSV(List<List<dynamic>> list) {
  //   return ListToCsvConverter().convert(list);
  // }

  BTSimulationInput parseCSV(String csvString) {
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);
    SplayTreeMap<String, Map<String, double>> result = SplayTreeMap();
    List<String> headers = [];
    for (var count = 0; count < rowsAsListOfValues.length; count++) {
      final row = rowsAsListOfValues[count];
      int columnSize = row.length;
      if (count == 0) {
        row.map((e) {
          String? header = tryCast<String>(e);
          if (header == null) {
            throw FormatException("Header cannot be casted to String");
          }
          headers.add(header);
        });
        continue;
      }
      String date = "";
      Map<String, double> currentCandleStick = {};
      for (var i = 0; i < columnSize; i++) {
        if (i == 0) {
          String? tempDate = tryCast(row[i]);
          if (tempDate == null) {
            throw FormatException("Date cannot be casted to String.");
          }
          date = tempDate;
          continue;
        }
        double? value = tryCast(row[i]);
        if (value == null) {
          throw FormatException("Number cannot be casted to Double.");
        }
        currentCandleStick[headers[i]] = value;
      }
      result[date] = currentCandleStick;
    }
    return BTSimulationInput(result, headers);
  }
}

class BTSimulationInput {
  BTSimulationInput(this.candleSticks, this.headers) : defaultHeaders = headers;

  final Headers defaultHeaders;
  CandleSticks candleSticks;
  Headers headers;

  void createColumn(int figure, BTIndicator indicator, String columnName) {
    if (figure.isNegative) {
      throw FormatException("Input figure should be a positive number.");
    }
    if (defaultHeaders.contains(columnName)) {
      throw Exception(
          "Cannot create column with name same as default column name.");
    }
    switch (indicator) {
      case BTIndicator.sma:
        createSMA(figure, columnName);
        break;
      // TODO: Implement remaining BTIndicator
      default:
        throw UnimplementedError(
            'No implementation found for this BTIndicator Type.');
    }
  }

  void removeColumn(String columnName) {
    if (defaultHeaders.contains(columnName)) {
      throw Exception(
          "Cannot remove column with name same as default column name.");
    }
    headers.remove(columnName);
    for (final key in candleSticks.keys) {
      candleSticks[key]!.remove(columnName);
    }
  }

  void renameColumn(String columnNameBefore, String columnNameAfter) {
    if (defaultHeaders.contains(columnNameBefore)) {
      throw Exception(
          "Cannot rename column with name same as default column name.");
    }
    if (defaultHeaders.contains(columnNameAfter)) {
      throw Exception(
          "Cannot rename column to name same as default column name.");
    }
    int index = headers.indexOf(columnNameBefore);
    headers[index] = columnNameAfter;
    for (final key in candleSticks.keys) {
      double? tempValue = candleSticks[key]![columnNameBefore]!;
      candleSticks[key]![columnNameAfter] = tempValue;
      candleSticks[key]!.remove(columnNameBefore);
    }
  }
}

extension SMA on BTSimulationInput {
  void createSMA(int average, String columnName) {
    final ListQueue<double> result = ListQueue<double>();
    ListQueue<double> tempPricing = getClosingPrice();
    for (var i = 0; i < tempPricing.length - average; i++) {
      result.add(calculateSMAValue(i, average, tempPricing));
    }
    headers.add(columnName);
    for (final i in candleSticks.keys.toList().reversed) {
      candleSticks[i]![BTIndicator.sma.getIndicatorName(columnName)] =
          result.removeLast();
    }
    return;
  }

  double calculateSMAValue(
      int start, int period, final ListQueue<double> prices) {
    return prices
            .toList()
            .sublist(start, start + period)
            .reduce((value, element) => value + element) /
        period;
  }
}

extension Constant on BTSimulationInput {
  void createConstant(int figure, String columnName) {
    for (final i in candleSticks.keys) {
      candleSticks[i]![BTIndicator.constant.getIndicatorName(columnName)] =
          figure.toDouble();
    }
    return;
  }
}

extension RSI on BTSimulationInput {
  void createRsi(int figure, String columnName) {
    final ListQueue<double> gainQueue = ListQueue<double>();
    final ListQueue<double> lossQueue = ListQueue<double>();
    final List<double> rsiResult = [];
    double? current;
    for (final key in candleSticks.keys) {
      if (current == null) {
        current = candleSticks[key]!["close"];
        continue;
      }
      if (gainQueue.length + lossQueue.length < figure) {
        rsiResult.add(BTIndicator.rsi.defaultValue);
        continue;
      }
      double diff = candleSticks[key]!["close"]! - current;
      if (diff.isNegative) {
        lossQueue.add(diff.abs());
        lossQueue.removeFirst();
      } else {
        gainQueue.add(diff);
        gainQueue.removeFirst();
      }
      current = candleSticks[key]!["close"];
      double avgGain = gainQueue.fold(
              0.0, (previousValue, element) => previousValue + element) /
          figure;
      double avgLoss = lossQueue.fold(
              0.0, (previousValue, element) => previousValue + element) /
          figure;
      double rs = avgGain / avgLoss;
      double rsi = 100 - (100 / (1 + rs));
      rsiResult.add(rsi);
    }
    headers.add(columnName);
    for (final i in candleSticks.keys.toList().reversed) {
      candleSticks[i]![BTIndicator.rsi.getIndicatorName(columnName)] =
          rsiResult.removeLast();
    }
    return;
  }
}

extension EMA on BTSimulationInput {
  void createEMA(int average, String columnName) {
    ListQueue<double> tempPricing = getClosingPrice();
    final emaValues = calculateEMA(tempPricing, average);
    headers.add(columnName);
    for (final i in candleSticks.keys.toList().reversed) {
      candleSticks[i]![BTIndicator.ema.getIndicatorName(columnName)] =
          emaValues.removeLast();
    }
  }

  ListQueue<double> calculateEMA(final ListQueue<double> prices, int period) {
    ListQueue<double> ema = ListQueue<double>();
    double multiplier = 2 / (period + 1);
    double sma = prices
            .toList()
            .sublist(0, period)
            .reduce((value, element) => value + element) /
        period;
    ema.add(sma);
    for (var i = period; i < prices.length; i++) {
      double currentPrice = prices.toList()[i];
      double previousEMA = ema.last;
      double currentEMA =
          (currentPrice - previousEMA) * multiplier + previousEMA;
      ema.add(currentEMA);
    }
    return ema;
  }
}

extension StochasticSlow on BTSimulationInput {
  void createStochasticSlow(
      int kPeriod, int dPeriod, int slowingPeriod, String columnName) {
    ListQueue<double> tempPricing = getClosingPrice();
    ListQueue<double> tempKValues = ListQueue<double>();
    ListQueue<double> kValues = ListQueue<double>();
    ListQueue<double> dValues = ListQueue<double>();
    ListQueue<double> sliding = ListQueue<double>();
    while (sliding.length < kPeriod - 1) {
      sliding.add(tempPricing.removeFirst());
    }
    while (tempPricing.isNotEmpty) {
      sliding.add(tempPricing.removeFirst());
      if (sliding.length > kPeriod) {
        sliding.removeFirst();
      }
      double currentClose = sliding.last;
      double lowestLow =
          sliding.reduce((value, element) => value < element ? value : element);
      double highestHigh =
          sliding.reduce((value, element) => value > element ? value : element);
      double k = ((currentClose - lowestLow) / (highestHigh - lowestLow)) * 100;

      tempKValues.add(k);
      if (tempKValues.length < dPeriod) {
        continue;
      } else if (tempKValues.length > dPeriod) {
        tempKValues.removeFirst();
      }
      kValues.add(tempKValues.fold(
              0.0, (previousValue, element) => previousValue + element) /
          dPeriod);
      if (kValues.length < slowingPeriod) {
        continue;
      }
      double d = kValues
              .toList()
              .sublist(kValues.length - slowingPeriod)
              .fold(0.0, (previousValue, element) => previousValue + element) /
          slowingPeriod;
      dValues.add(d);
    }
    headers.add(columnName);
    for (final key in candleSticks.keys.toList().reversed) {
      candleSticks[key]![BTIndicator.stochasticSlowPercentK
          .getIndicatorName(columnName)] = kValues.removeLast();
      candleSticks[key]![BTIndicator.stochasticSlowPercentD
          .getIndicatorName(columnName)] = dValues.removeLast();
    }
  }
}

extension StochasticFast on BTSimulationInput {
  void createStochasticFast(int kPeriod, int dPeriod, String columnName) {
    ListQueue<double> tempPricing = getClosingPrice();
    ListQueue<double> kValues = ListQueue<double>();
    ListQueue<double> dValues = ListQueue<double>();
    ListQueue<double> sliding = ListQueue<double>();
    while (sliding.length < kPeriod - 1) {
      sliding.add(tempPricing.removeFirst());
    }
    while (tempPricing.isNotEmpty) {
      sliding.add(tempPricing.removeFirst());
      if (sliding.length > kPeriod) {
        sliding.removeFirst();
      }
      double currentClose = sliding.last;
      double lowestLow =
          sliding.reduce((value, element) => value < element ? value : element);
      double highestHigh =
          sliding.reduce((value, element) => value > element ? value : element);
      double k = ((currentClose - lowestLow) / (highestHigh - lowestLow)) * 100;
      kValues.add(k);
      if (kValues.length < dPeriod) {
        continue;
      }
      double d = kValues
              .toList()
              .sublist(kValues.length - dPeriod)
              .fold(0.0, (previousValue, element) => previousValue + element) /
          dPeriod;
      dValues.add(d);
    }
    headers.add(columnName);
    for (final key in candleSticks.keys.toList().reversed) {
      candleSticks[key]![BTIndicator.stochasticFastPercentK
          .getIndicatorName(columnName)] = kValues.removeLast();
      candleSticks[key]![BTIndicator.stochasticFastPercentD
          .getIndicatorName(columnName)] = dValues.removeLast();
    }
  }
}

extension MACD on BTSimulationInput {
  void createMACD(int shortEMA, int longEMA, int signalEMA, String columnName) {
    ListQueue<double> tempPricing = getClosingPrice();
    ListQueue<double> emaShort = calculateEMA(tempPricing, shortEMA);
    ListQueue<double> emaLong = calculateEMA(tempPricing, longEMA);
    ListQueue<double> macdLine = ListQueue<double>();
    var i = emaLong.length;
    final diff = emaShort.length - emaLong.length;
    while (i != 0) {
      macdLine.addFirst(emaShort.elementAt(i + diff) - emaLong.elementAt(i));
      i--;
    }
    ListQueue<double> signalLine = calculateEMA(macdLine, signalEMA);
    ListQueue<double> histogram = ListQueue<double>();
    var j = emaLong.length;
    final diff2 = macdLine.length - signalLine.length;
    while (j != 0) {
      histogram
          .addFirst(macdLine.elementAt(i + diff2) - signalLine.elementAt(i));
      j--;
    }
    headers.add(columnName);
    for (final key in candleSticks.keys.toList().reversed) {
      candleSticks[key]![BTIndicator.macdHistogram
          .getIndicatorName(columnName)] = histogram.removeLast();
      candleSticks[key]![BTIndicator.macdMacdLine
          .getIndicatorName(columnName)] = macdLine.removeLast();
      candleSticks[key]![BTIndicator.macdEmaShort
          .getIndicatorName(columnName)] = emaShort.removeLast();
      candleSticks[key]![BTIndicator.macdEmaLong.getIndicatorName(columnName)] =
          emaLong.removeLast();
      candleSticks[key]![BTIndicator.macdSignal.getIndicatorName(columnName)] =
          signalLine.removeLast();
    }
  }
}

//TODO: double check implementation
extension Bollinger on BTSimulationInput {
  void createBollingerBand(int period, double stdDevFactor, String columnName) {
    ListQueue<double> prices = getClosingPrice();
    ListQueue<double> smaValues = ListQueue<double>();
    ListQueue<double> upperBand = ListQueue<double>();
    ListQueue<double> lowerBand = ListQueue<double>();

    for (int i = period - 1; i < prices.length; i++) {
      double sma = prices
              .toList()
              .sublist(i - period + 1, i + 1)
              .reduce((a, b) => a + b) /
          period;
      double stdDev = sqrt(prices
              .toList()
              .sublist(i - period + 1, i + 1)
              .map((price) => pow(price - sma, 2))
              .reduce((a, b) => a + b) /
          period);
      smaValues.add(sma);
      upperBand.add(sma + stdDevFactor * stdDev);
      lowerBand.add(sma - stdDevFactor * stdDev);
    }
    headers.add(columnName);
    for (final key in candleSticks.keys.toList().reversed) {
      candleSticks[key]![BTIndicator.bollingerUpper
          .getIndicatorName(columnName)] = upperBand.removeLast();
      candleSticks[key]![BTIndicator.bollingerLower
          .getIndicatorName(columnName)] = lowerBand.removeLast();
      candleSticks[key]![BTIndicator.bollingerMiddle
          .getIndicatorName(columnName)] = smaValues.removeLast();
    }
  }
}

extension ClosingPrice on BTSimulationInput {
  ListQueue<double> getClosingPrice() {
    ListQueue<double> tempPricing = ListQueue<double>();
    for (var i = 0; i < candleSticks.length; i++) {
      tempPricing.add(candleSticks[i]!["close"]!);
    }
    return tempPricing;
  }
}

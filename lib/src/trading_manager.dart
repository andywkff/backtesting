import 'package:backtesting/backtesting.dart';
import 'package:tuple/tuple.dart';

class BTTradingManager {
  List<BTTrade> backtest(BTSimulationInput input, BTBacktestOptions options) {
    List<BTTrade> completedTrades = [];
    BTTrade? currentPosition;
    PositionStatus positionStatus = PositionStatus.none;
    input.candleSticks.forEach((timestamp, currentBar) {
      // 1. stopLoss / trailingStopLoss
      // 2. profit target
      // 3. enterRule
      // 4. exitRule
      // 5. keep holding position
      // 6. finalize last candlestick

      switch (positionStatus) {
        CurrentPositionEmpty:
        case PositionStatus.none:
          if (!isNull(currentPosition)) {
            positionStatus = PositionStatus.position;
            continue CurrentPositionNotEmpty;
          }
          if (options.entryRule(currentBar)) {
            positionStatus = PositionStatus.enter;
            // if (options.sameDayExecution) {
            //   continue SameDayExecution;
            // }
            // break;
          }
        SameDayExecution:
        case PositionStatus.enter:
          if (!isNull(currentPosition)) {
            positionStatus = PositionStatus.position;
            continue CurrentPositionNotEmpty;
          }
          currentPosition = _enterPosition(timestamp, currentBar, options);
          positionStatus = PositionStatus.position;
          break;
        CurrentPositionNotEmpty:
        case PositionStatus.position:
          if (isNull(currentPosition)) {
            positionStatus = PositionStatus.none;
            continue CurrentPositionEmpty;
          }
          // currentTrade!.holdingPeriod++;
          if (currentBar["close"]! < currentPosition!.stopPrice) {
            positionStatus = PositionStatus.exit;
            currentPosition!.exitReason = BTTradeExitReason.stopLoss;
            currentPosition = _updatePosition(
                timestamp, currentBar, currentPosition!, false, options);
          } else if (currentBar["close"]! > currentPosition!.profitTarget) {
            positionStatus = PositionStatus.exit;
            currentPosition!.exitReason = BTTradeExitReason.profitTarget;
            currentPosition = _updatePosition(
                timestamp, currentBar, currentPosition!, false, options);
          } else if (options.exitRule(currentBar)) {
            positionStatus = PositionStatus.exit;
            currentPosition!.exitReason = BTTradeExitReason.exitRule;
            currentPosition = _updatePosition(
                timestamp, currentBar, currentPosition!, false, options);
          } else {
            currentPosition = _updatePosition(
                timestamp, currentBar, currentPosition!, true, options);
          }
        // update holding period and new stop price and so on
        case PositionStatus.exit:
          if (isNull(currentPosition)) {
            positionStatus = PositionStatus.none;
            continue CurrentPositionEmpty;
          }
          currentPosition =
              _exitPosition(timestamp, currentBar, currentPosition!, options);
          completedTrades.add(currentPosition!);
          currentPosition = null;
          positionStatus = PositionStatus.none;
          break;
      }
    });
    // MARK: finialize position
    if (positionStatus == PositionStatus.position) {
      if (isNull(currentPosition)) {
        positionStatus = PositionStatus.none;
      } else {
        final latest = input.candleSticks.lastKey();
        currentPosition = _finalizePosition(
            latest!, input.candleSticks[latest]!, currentPosition!, options);
        completedTrades.add(currentPosition!);
      }
    }
    return completedTrades;
  }

  void optimize() {}

// MARK: for holding position during simulation
  BTTrade _updatePosition(
      String timestamp,
      Map<String, double> currentBar,
      BTTrade currentTrade,
      bool updateTradeProperties,
      BTBacktestOptions options) {
    // TODO: update stopLoss Price and other related currentPosition-details
    currentTrade.holdingPeriod++;
    if (!updateTradeProperties) {
      return currentTrade;
    }

    return currentTrade;
  }

  BTTrade _enterPosition(String timestamp, Map<String, double> currentBar,
      BTBacktestOptions options) {
    final currentTrade = BTTrade();
    currentTrade.direction = options.primaryTradeDirection;
    currentTrade.entryPrice =
        currentBar[BTIndicator.open.getIndicatorName("")]!;
    currentTrade.entryTime = timestamp;
    return currentTrade;
  }

  BTTrade _exitPosition(String timestamp, Map<String, double> currentBar,
      BTTrade currentTrade, BTBacktestOptions options) {
    currentTrade.exitPrice = currentBar[BTIndicator.open.getIndicatorName("")]!;
    currentTrade.exitTime = timestamp;
    return currentTrade;
  }

// MARK: for still holding position after last candlestick
  BTTrade _finalizePosition(String timestamp, Map<String, double> currentBar,
      BTTrade currentTrade, BTBacktestOptions options) {
    currentTrade.exitPrice =
        currentBar[BTIndicator.close.getIndicatorName("")]!;
    currentTrade.exitTime = timestamp;
    return currentTrade;
  }

  Tuple2<CheckingFn, CheckingFn> getCheckFn(SimulationPolicyConfig config) {
    entryCheckingFn(Map<String, double> currentBar) {
      List<bool> entryRulesEntry = [];
      for (final element in config.entryRules) {
        double valueOne = 0.0;
        double valueTwo = 0.0;
        String indicatorOneNaming =
            element.indicatorOneType.getIndicatorName(element.indicatorOneName);
        String indicatorTwoNaming =
            element.indicatorTwoType.getIndicatorName(element.indicatorTwoName);
        valueOne = currentBar[indicatorOneNaming]!;
        valueTwo = currentBar[indicatorTwoNaming]!;
        final bool temp =
            _compareResult(element.compareOption, valueOne, valueTwo);
        entryRulesEntry.add(temp);
      }
      return !entryRulesEntry.contains(false);
    }

    exitCheckingFn(Map<String, double> currentBar) {
      List<bool> exitRulesEntry = [];
      for (var element in config.exitRules) {
        double valueOne = 0.0;
        double valueTwo = 0.0;
        String indicatorOneNaming =
            element.indicatorOneType.getIndicatorName(element.indicatorOneName);
        String indicatorTwoNaming =
            element.indicatorTwoType.getIndicatorName(element.indicatorTwoName);
        valueOne = currentBar[indicatorOneNaming]!;
        valueTwo = currentBar[indicatorTwoNaming]!;
        final bool temp =
            _compareResult(element.compareOption, valueOne, valueTwo);
        exitRulesEntry.add(temp);
      }
      return !exitRulesEntry.contains(false);
    }

    return Tuple2(entryCheckingFn, exitCheckingFn);
  }

  bool _compareResult(
      CompareOption compareOption, double value1, double value2) {
    switch (compareOption) {
      case CompareOption.largerOrEqualTo:
        return value1 >= value2;
      case CompareOption.largerThan:
        return value1 > value2;
      case CompareOption.equalTo:
        return value1 == value2;
      case CompareOption.smallThan:
        return value1 < value2;
      case CompareOption.smallerOrEqualTo:
        return value1 <= value2;
    }
  }
}

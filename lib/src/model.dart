import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

part 'model.g.dart';

typedef CandleSticks = SplayTreeMap<String, Map<String, double>>;
typedef Headers = List<String>;
typedef CheckingFn = bool Function(Map<String, double> currentCandle);

enum BTIndicator {
  sma,
  ema,
  macdEmaShort,
  macdEmaLong,
  macdMacdLine,
  macdHistogram,
  macdSignal,
  bollingerUpper,
  bollingerLower,
  bollingerMiddle,
  rsi,
  stochasticSlowPercentD,
  stochasticSlowPercentK,
  stochasticFastPercentD,
  stochasticFastPercentK,
  constant,
  close,
  open,
  high,
  low,
  volume
}

extension ColumnName on BTIndicator {
  String getIndicatorName(String name) {
    var result = "";
    switch (this) {
      case BTIndicator.sma:
        result = "$name${BTIndicator.sma.name}";
      case BTIndicator.ema:
        result = "$name${BTIndicator.ema.name}";
      case BTIndicator.macdEmaShort:
        result = "$name${BTIndicator.macdEmaShort.name}";
      case BTIndicator.macdMacdLine:
        result = "$name${BTIndicator.macdMacdLine.name}";
      case BTIndicator.macdHistogram:
        result = "$name${BTIndicator.macdHistogram.name}";
      case BTIndicator.macdSignal:
        result = "$name${BTIndicator.macdSignal.name}";
      case BTIndicator.macdEmaLong:
        result = "$name${BTIndicator.macdEmaLong.name}";
      case BTIndicator.bollingerUpper:
        result = "$name${BTIndicator.bollingerUpper.name}";
      case BTIndicator.bollingerLower:
        result = "$name${BTIndicator.bollingerLower.name}";
      case BTIndicator.bollingerMiddle:
        result = "$name${BTIndicator.bollingerMiddle.name}";
      case BTIndicator.rsi:
        result = "$name${BTIndicator.rsi.name}";
      case BTIndicator.stochasticSlowPercentD:
        result = "$name${BTIndicator.stochasticSlowPercentD.name}";
      case BTIndicator.stochasticSlowPercentK:
        result = "$name${BTIndicator.stochasticSlowPercentK.name}";
      case BTIndicator.stochasticFastPercentD:
        result = "$name${BTIndicator.stochasticFastPercentD.name}";
      case BTIndicator.stochasticFastPercentK:
        result = "$name${BTIndicator.stochasticFastPercentK.name}";
      case BTIndicator.constant:
        result = "$name${BTIndicator.constant.name}";
      case BTIndicator.close:
        result = BTIndicator.close.name;
      case BTIndicator.open:
        result = BTIndicator.open.name;
      case BTIndicator.high:
        result = BTIndicator.high.name;
      case BTIndicator.low:
        result = BTIndicator.low.name;
      case BTIndicator.volume:
        result = BTIndicator.volume.name;
    }
    return result;
  }
}

enum SimulationTimeframe {
  sixMonths,
  oneYear,
  twoYears,
  threeYears,
  fourYears,
  fiveYears,
  present
}

enum BTTradeExitReason { stopLoss, exitRule, entryRule, profitTarget, finalize }

enum SimulationStatus { pending, simulating, finished, failed }

enum ATMinMax { min, max }

enum ATEntitlement { pro, standard }

enum CompareOption {
  largerOrEqualTo,
  largerThan,
  equalTo,
  smallThan,
  smallerOrEqualTo
}

extension Reverse on CompareOption {
  CompareOption get reverseOption {
    switch (this) {
      case CompareOption.equalTo:
        return this;
      case CompareOption.largerOrEqualTo:
        return CompareOption.smallThan;
      case CompareOption.largerThan:
        return CompareOption.smallerOrEqualTo;
      case CompareOption.smallThan:
        return CompareOption.largerOrEqualTo;
      case CompareOption.smallerOrEqualTo:
        return CompareOption.largerThan;
      default:
        return CompareOption.equalTo;
    }
  }
}

enum SimulationPolicy {
  sma,
  ema,
  macd,
  stochasticSlow,
  stochasticFast,
  bollinger,
  custom
}

enum PositionStatus {
  none,
  enter,
  position,
  exit,
}

enum TradeDirection { long, short }

extension DefaultIndicator on BTIndicator {
  double get defaultValue => -999.999;
}

@JsonSerializable()
class ATTimestampedValue {
  String time = "";
  double value = 0.0;
}

@JsonSerializable()
class BTAnalysisResult {
  double ATMaxDownDraw = 0.0;
  double ATMaxDownDrawPct = 0.0;
  double startingCapital = 0.0;
  double finalCapital = 0.0;
  double profit = 0.0;
  double profitPct = 0.0;
  double growth = 0.0;
  double totalTrades = 0.0;
  double barCount = 0.0;
  double maxDrawdown = 0.0;
  double maxDrawdownPct = 0.0;
  double maxRiskPct = 0.0;
  double rmultipleStdDev = 0.0;
  double expectency = 0.0;
  double systemQuality = 0.0;
  double profitFactor = 0.0;
  double proportionProfitable = 0.0;
  double percentProfitable = 0.0;
  double returnOnAccount = 0.0;
  double averageProfitPerTrade = 0.0;
  double numWinningTrades = 0.0;
  double numLosingTrades = 0.0;
  double averageWinningTrade = 0.0;
  double averageLosingTrade = 0.0;
  double expectedValue = 0.0;
}

@JsonSerializable()
class BTTrade {
  TradeDirection direction = TradeDirection.long;
  String entryTime = "";
  double entryPrice = 0.0;
  String exitTime = "";
  double exitPrice = 0.0;
  double profit = 0.0;
  double profitPct = 0.0;
  double growth = 0.0;
  double riskPct = 0.0;
  double rmultiple = 0.0;
  List<ATTimestampedValue>? riskSeries = [];
  int holdingPeriod = 0;
  BTTradeExitReason exitReason = BTTradeExitReason.exitRule;
  double stopPrice = 0.0;
  List<ATTimestampedValue> stopPriceSeries = [];
  double profitTarget = 0.0;
}

// TODO: resolve Tuple for Json Deserialisation
// @JsonSerializable()
class SimulationRule {
  String indicatorOneName = "";
  BTIndicator indicatorOneType = BTIndicator.close;
  Tuple3<double, double, double> indicatorOneFigure = Tuple3(0.0, 0.0, 0.0);
  String indicatorTwoName = "";
  BTIndicator indicatorTwoType = BTIndicator.close;
  Tuple3<double, double, double> indicatorTwoFigure = Tuple3(0.0, 0.0, 0.0);
  CompareOption compareOption = CompareOption.equalTo;
}

// @JsonSerializable()
class OptimizeConfigOutput {
  BTAnalysisResult analysis = BTAnalysisResult();
  List<BTTrade> trades = [];
  SimulationPolicyConfig config = SimulationPolicyConfig();
}

// @JsonSerializable()
class SimulateConfigOutput {
  BTAnalysisResult analysis = BTAnalysisResult();
  List<BTTrade> trades = [];
  SimulationPolicyConfig config = SimulationPolicyConfig();
}

// @JsonSerializable()
class SimulationPolicyConfig {
  SimulationPolicy policy = SimulationPolicy.sma;
  bool trailingStopLoss = true;
  double stopLossFigure = 0.0;
  double profitFactor = 0.0;
  List<SimulationRule> entryRules = [];
  List<SimulationRule> exitRules = [];
  double t1 = 0.0;
  double t2 = 0.0;
}

// @JsonSerializable()
class OptimizePolicyConfig {
  int stepSize = 1;
  bool simplePolicy = true;
  bool trailingStopLoss = true;
  int stopLossFigure = 0;
  int profitFactor = 0;
  List<OptimizeRule> entryRules = [];
  List<OptimizeRule> exitRules = [];
  double t1 = 0.0;
  double t2 = 0.0;
}

// TODO: resolve Tuple for Json Deserialisation
// @JsonSerializable()
class OptimizeRule {
  String indicatorOneName = "";
  BTIndicator indicatorOneType = BTIndicator.close;
  Tuple3<double, double, double> indicatorOneFigureLower =
      Tuple3(0.0, 0.0, 0.0);
  Tuple3<double, double, double> indicatorOneFigureUpper =
      Tuple3(0.0, 0.0, 0.0);
  String indicatorTwoName = "";
  BTIndicator indicatorTwoType = BTIndicator.close;
  Tuple3<double, double, double> indicatorTwoFigureLower =
      Tuple3(0.0, 0.0, 0.0);
  Tuple3<double, double, double> indicatorTwoFigureUpper =
      Tuple3(0.0, 0.0, 0.0);
  CompareOption compareOption = CompareOption.equalTo;
}

@JsonSerializable()
class OptimizeRulesContainer {}

// @JsonSerializable()
class BTBacktestOptions {
  CheckingFn entryRule;
  CheckingFn exitRule;
  double profitFactor = 0.0;
  double riskPct = 15.0;
  TradeDirection primaryTradeDirection = TradeDirection.long;
  bool trailingStopLoss = true;
  bool intraDayStopLossProfitTarget = false;
  bool sameDayExecution = false;
  bool intraDayHighForTrailingStopLoss = false;
  bool immediateInvoke = false;
  BTBacktestOptions(this.entryRule, this.exitRule);
}

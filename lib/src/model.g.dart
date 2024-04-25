// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ATTimestampedValue _$ATTimestampedValueFromJson(Map<String, dynamic> json) =>
    ATTimestampedValue()
      ..time = json['time'] as String
      ..value = (json['value'] as num).toDouble();

Map<String, dynamic> _$ATTimestampedValueToJson(ATTimestampedValue instance) =>
    <String, dynamic>{
      'time': instance.time,
      'value': instance.value,
    };

BTAnalysisResult _$BTAnalysisResultFromJson(Map<String, dynamic> json) =>
    BTAnalysisResult()
      ..ATMaxDownDraw = (json['ATMaxDownDraw'] as num).toDouble()
      ..ATMaxDownDrawPct = (json['ATMaxDownDrawPct'] as num).toDouble()
      ..startingCapital = (json['startingCapital'] as num).toDouble()
      ..finalCapital = (json['finalCapital'] as num).toDouble()
      ..profit = (json['profit'] as num).toDouble()
      ..profitPct = (json['profitPct'] as num).toDouble()
      ..growth = (json['growth'] as num).toDouble()
      ..totalTrades = (json['totalTrades'] as num).toDouble()
      ..barCount = (json['barCount'] as num).toDouble()
      ..maxDrawdown = (json['maxDrawdown'] as num).toDouble()
      ..maxDrawdownPct = (json['maxDrawdownPct'] as num).toDouble()
      ..maxRiskPct = (json['maxRiskPct'] as num).toDouble()
      ..rmultipleStdDev = (json['rmultipleStdDev'] as num).toDouble()
      ..expectency = (json['expectency'] as num).toDouble()
      ..systemQuality = (json['systemQuality'] as num).toDouble()
      ..profitFactor = (json['profitFactor'] as num).toDouble()
      ..proportionProfitable = (json['proportionProfitable'] as num).toDouble()
      ..percentProfitable = (json['percentProfitable'] as num).toDouble()
      ..returnOnAccount = (json['returnOnAccount'] as num).toDouble()
      ..averageProfitPerTrade =
          (json['averageProfitPerTrade'] as num).toDouble()
      ..numWinningTrades = (json['numWinningTrades'] as num).toDouble()
      ..numLosingTrades = (json['numLosingTrades'] as num).toDouble()
      ..averageWinningTrade = (json['averageWinningTrade'] as num).toDouble()
      ..averageLosingTrade = (json['averageLosingTrade'] as num).toDouble()
      ..expectedValue = (json['expectedValue'] as num).toDouble();

Map<String, dynamic> _$BTAnalysisResultToJson(BTAnalysisResult instance) =>
    <String, dynamic>{
      'ATMaxDownDraw': instance.ATMaxDownDraw,
      'ATMaxDownDrawPct': instance.ATMaxDownDrawPct,
      'startingCapital': instance.startingCapital,
      'finalCapital': instance.finalCapital,
      'profit': instance.profit,
      'profitPct': instance.profitPct,
      'growth': instance.growth,
      'totalTrades': instance.totalTrades,
      'barCount': instance.barCount,
      'maxDrawdown': instance.maxDrawdown,
      'maxDrawdownPct': instance.maxDrawdownPct,
      'maxRiskPct': instance.maxRiskPct,
      'rmultipleStdDev': instance.rmultipleStdDev,
      'expectency': instance.expectency,
      'systemQuality': instance.systemQuality,
      'profitFactor': instance.profitFactor,
      'proportionProfitable': instance.proportionProfitable,
      'percentProfitable': instance.percentProfitable,
      'returnOnAccount': instance.returnOnAccount,
      'averageProfitPerTrade': instance.averageProfitPerTrade,
      'numWinningTrades': instance.numWinningTrades,
      'numLosingTrades': instance.numLosingTrades,
      'averageWinningTrade': instance.averageWinningTrade,
      'averageLosingTrade': instance.averageLosingTrade,
      'expectedValue': instance.expectedValue,
    };

BTTrade _$BTTradeFromJson(Map<String, dynamic> json) => BTTrade()
  ..direction = $enumDecode(_$TradeDirectionEnumMap, json['direction'])
  ..entryTime = json['entryTime'] as String
  ..entryPrice = (json['entryPrice'] as num).toDouble()
  ..exitTime = json['exitTime'] as String
  ..exitPrice = (json['exitPrice'] as num).toDouble()
  ..profit = (json['profit'] as num).toDouble()
  ..profitPct = (json['profitPct'] as num).toDouble()
  ..growth = (json['growth'] as num).toDouble()
  ..riskPct = (json['riskPct'] as num).toDouble()
  ..rmultiple = (json['rmultiple'] as num).toDouble()
  ..riskSeries = (json['riskSeries'] as List<dynamic>?)
      ?.map((e) => ATTimestampedValue.fromJson(e as Map<String, dynamic>))
      .toList()
  ..holdingPeriod = json['holdingPeriod'] as int
  ..exitReason = $enumDecode(_$BTTradeExitReasonEnumMap, json['exitReason'])
  ..stopPrice = (json['stopPrice'] as num).toDouble()
  ..stopPriceSeries = (json['stopPriceSeries'] as List<dynamic>)
      .map((e) => ATTimestampedValue.fromJson(e as Map<String, dynamic>))
      .toList()
  ..profitTarget = (json['profitTarget'] as num).toDouble();

Map<String, dynamic> _$BTTradeToJson(BTTrade instance) => <String, dynamic>{
      'direction': _$TradeDirectionEnumMap[instance.direction]!,
      'entryTime': instance.entryTime,
      'entryPrice': instance.entryPrice,
      'exitTime': instance.exitTime,
      'exitPrice': instance.exitPrice,
      'profit': instance.profit,
      'profitPct': instance.profitPct,
      'growth': instance.growth,
      'riskPct': instance.riskPct,
      'rmultiple': instance.rmultiple,
      'riskSeries': instance.riskSeries,
      'holdingPeriod': instance.holdingPeriod,
      'exitReason': _$BTTradeExitReasonEnumMap[instance.exitReason]!,
      'stopPrice': instance.stopPrice,
      'stopPriceSeries': instance.stopPriceSeries,
      'profitTarget': instance.profitTarget,
    };

const _$TradeDirectionEnumMap = {
  TradeDirection.long: 'long',
  TradeDirection.short: 'short',
};

const _$BTTradeExitReasonEnumMap = {
  BTTradeExitReason.stopLoss: 'stopLoss',
  BTTradeExitReason.exitRule: 'exitRule',
  BTTradeExitReason.entryRule: 'entryRule',
  BTTradeExitReason.profitTarget: 'profitTarget',
  BTTradeExitReason.finalize: 'finalize',
};

OptimizeRulesContainer _$OptimizeRulesContainerFromJson(
        Map<String, dynamic> json) =>
    OptimizeRulesContainer();

Map<String, dynamic> _$OptimizeRulesContainerToJson(
        OptimizeRulesContainer instance) =>
    <String, dynamic>{};

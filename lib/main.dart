import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models/monster_parameter.dart';

void main() {
  runApp(const MyApp());
}

class _HistoryColumn {
  const _HistoryColumn({
    required this.label,
    required this.cellBuilder,
    this.isNumeric = false,
    this.visibleInStandard = true,
  });

  final String label;
  final bool isNumeric;
  final bool visibleInStandard;
  final Widget Function(MonsterHistory history) cellBuilder;
}

class _WeeklyEffects {
  const _WeeklyEffects({
    this.lifespan = 0,
    this.affection = 0,
    this.affectionMul = 1.0,
    this.fear = 0,
    this.fearMul = 1.0,
    this.fatigue = 0,
    this.stress = 0,
    this.bodyValue = 0,
    this.gBalance = 0,
  });

  final int lifespan;
  final int affection;
  final double affectionMul;
  final int fear;
  final double fearMul;
  final int fatigue;
  final int stress;
  final int bodyValue;
  final int gBalance;

  _WeeklyEffects operator +(_WeeklyEffects other) {
    return _WeeklyEffects(
      lifespan: lifespan + other.lifespan,
      affection: affection + other.affection,
      fear: fear + other.fear,
      fatigue: fatigue + other.fatigue,
      stress: stress + other.stress,
      bodyValue: bodyValue + other.bodyValue,
      gBalance: gBalance + other.gBalance,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monster farm visualizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Monster farm visualizer Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedSidebarIndex = 0;
  final List<MonsterHistory> _historyEntries = [
    MonsterHistory(
      year: 1,
      month: 4,
      week: 1,
      lifespan: 120,
      lifespanPercent: 0.95,
      ageYears: 0,
      ageMonths: 3,
      ageWeeks: 0,
      fatigue: 12,
      stress: 8,
      affection: 60,
      fear: 20,
      loyalty: 55,
      stressGain: 6,
      bodyValue: 0,
      bodyType: BodyType.normal,
      condition: 85,
      lifeCost: 2,
      action: MonsterAction.lightWork,
      monthlyFeed: MonsterFeed.potato,
      mango: 1,
      mochi: 0,
      grass: 0,
      gBalance: 520,
    ),
    MonsterHistory(
      year: 1,
      month: 5,
      week: 2,
      lifespan: 112,
      lifespanPercent: 0.89,
      ageYears: 0,
      ageMonths: 4,
      ageWeeks: 1,
      fatigue: 25,
      stress: 14,
      affection: 68,
      fear: 18,
      loyalty: 60,
      stressGain: 8,
      bodyValue: 0,
      bodyType: BodyType.small,
      condition: 78,
      lifeCost: 3,
      action: MonsterAction.heavyWork,
      monthlyFeed: MonsterFeed.fish,
      mango: 0,
      mochi: 1,
      grass: 0,
      gBalance: 460,
    ),
    MonsterHistory(
      year: 1,
      month: 6,
      week: 4,
      lifespan: 104,
      lifespanPercent: 0.81,
      ageYears: 0,
      ageMonths: 6,
      ageWeeks: 0,
      fatigue: 10,
      stress: 6,
      affection: 75,
      fear: 15,
      loyalty: 70,
      stressGain: 5,
      bodyValue: 0,
      bodyType: BodyType.big,
      condition: 92,
      lifeCost: 1,
      action: MonsterAction.heavyWork,
      monthlyFeed: MonsterFeed.meat,
      mango: 0,
      mochi: 0,
      grass: 2,
      gBalance: 580,
    ),
  ];

  static const int _initialLifespan = 300;

  List<MonsterHistory> _recalculateHistoryEntries() {
    if (_historyEntries.isEmpty) {
      return const <MonsterHistory>[];
    }

    final List<MonsterHistory> results = [];
    var previousLifespan = _initialLifespan;
    var previousAffection = 0;
    var previousFear = 0;
    var previousFatigue = 0;
    var previousStress = 0;
    var previousLoyalty = 0;
    var previousBodyValue = 0;
    var previousGBalance = 0;
    var accumulatedAgeWeeks = 0;

    for (var index = 0; index < _historyEntries.length; index++) {
      //get input information
      final entry = _historyEntries[index];

      //calculate effects from Items befor Actions.
      var effectsFromItems = _effectsFromFeed(entry.monthlyFeed) + _effectsFromItems(entry);

      var affection =
          _clampValidValue(previousAffection + effectsFromItems.affection, 0, 200);
      var fear = _clampValidValue(previousFear + effectsFromItems.fear, 0, 200);
      var fatigue =
          _clampValidValue(previousFatigue + effectsFromItems.fatigue, 0 ,100);
      var stress = _clampValidValue(previousStress + effectsFromItems.stress, 0, 100);
      var bodyValue = previousBodyValue + effectsFromItems.bodyValue;
      //final bodyType = func(bodyValue);

      //calculate effects from an Action.
      final effectsFromAction = _effectsFromAction(entry.action);

      affection =
          _clampValidValue(affection + effectsFromAction.affection, 0, 200);
      fear = _clampValidValue(fear + effectsFromAction.fear, 0, 200);
      fatigue =
          _clampValidValue(fatigue + effectsFromAction.fatigue, 0, 100);
      stress = _clampValidValue(stress + effectsFromAction.stress, 0, 100);
      bodyValue = bodyValue + effectsFromAction.bodyValue;
      final stressGain = _clampNonNegative(_floorDiv(fear - affection, 10));
      stress = _clampValidValue(stress + stressGain, 0, 100);

      final condition = _conditionValue(fatigue, stress);
      final lifeCost = _lifeCostFromCondition(condition);
      final lifespan = index == 0
          ? math.max(0, _initialLifespan - lifeCost)
          : math.max(0, previousLifespan - lifeCost);
      final lifespanPercent = index == 0 ? 1.0 : lifespan / _initialLifespan;

      if (index > 0) {
        accumulatedAgeWeeks += 1;
      }

      final ageYears = accumulatedAgeWeeks ~/ 48;
      final ageMonths = (accumulatedAgeWeeks % 48) ~/ 4;
      final ageWeeks = accumulatedAgeWeeks % 4;

      final loyalty = _calculateLoyalty(previousLoyalty, affection, fear);
      
      final gBalance = previousGBalance + effectsFromItems.gBalance + effectsFromAction.gBalance;

      results.add(
        MonsterHistory(
          year: entry.year,
          month: entry.month,
          week: entry.week,
          lifespan: lifespan,
          lifespanPercent: lifespanPercent,
          ageYears: ageYears,
          ageMonths: ageMonths,
          ageWeeks: ageWeeks,
          fatigue: fatigue,
          stress: stress,
          affection: affection,
          fear: fear,
          loyalty: loyalty,
          stressGain: stressGain,
          bodyValue: bodyValue,
          bodyType: entry.bodyType,
          condition: condition,
          lifeCost: lifeCost,
          action: entry.action,
          monthlyFeed: entry.monthlyFeed,
          mango: entry.mango,
          mochi: entry.mochi,
          grass: entry.grass,
          gBalance: gBalance,
        ),
      );

      previousAffection = affection;
      previousFear = fear;
      previousFatigue = fatigue;
      previousStress = stress;
      previousLoyalty = loyalty;
      previousBodyValue = bodyValue;
      previousGBalance = gBalance;
      previousLifespan = lifespan;
    }

    return results;
  }

  // Placeholder balance changes that combine user selections with previous state.
  _WeeklyEffects _effectsFromAction(MonsterAction action) {
    switch (action) {
      case MonsterAction.none:
        return const _WeeklyEffects(
        );
      case MonsterAction.lightWork:
        return const _WeeklyEffects(
          fatigue: 18,
          stress: 3,
          bodyValue: -2,
          gBalance: 100,
        );
      case MonsterAction.heavyWork:
        return const _WeeklyEffects(
          fatigue: 33,
          stress: 8,
          bodyValue: -3,
          gBalance: 150,
        );
      case MonsterAction.training:
        return const _WeeklyEffects(
          fatigue: 17,
          stress: 4,
          bodyValue: -4,
          gBalance: -150,
        );
      case MonsterAction.rest:
        return const _WeeklyEffects(
          fatigue: -55,
          stress: -8,
          bodyValue: 3,
        );
      case MonsterAction.tournament:
        return const _WeeklyEffects(
          lifespan: -2,
          fatigue: 30,
          stress: -60,
          gBalance: 800,
        );
      case MonsterAction.expedition:
        return const _WeeklyEffects(
        );
      case MonsterAction.expeditionReturn:
        return const _WeeklyEffects(
          fatigue: 70,
          stress: 10,
        );
      case MonsterAction.hibernation:
        return const _WeeklyEffects(
        );
    }
  }

  _WeeklyEffects _effectsFromFeed(MonsterFeed feed) {
    switch (feed) {
      case MonsterFeed.potato:
        return const _WeeklyEffects(
          affectionMul: 0.7,
          fearMul: 0.7,
          stress: 10,
          gBalance: -10,
        );
      case MonsterFeed.fish:
        return const _WeeklyEffects(
          bodyValue: 2,
          gBalance: -100,
        );
      case MonsterFeed.meat:
        return const _WeeklyEffects(
          lifespan: 1,
          affection: 3,
          bodyValue: 6,
          stress: -10,
          gBalance: -300,
        );
      case MonsterFeed.nothing:
        return const _WeeklyEffects(
        );
    }
  }

  _WeeklyEffects _effectsFromItems(MonsterHistory entry) { //have to add other items.
    final mangoEffect = _WeeklyEffects(
      affection: 1 * entry.mango,
      fear: 1 * entry.mango,
      fatigue: -10 * entry.mango,
      bodyValue: 1 * entry.mango,
      gBalance: -50 * entry.mango,
    );
    final mochiEffect = _WeeklyEffects(
      fatigue: -50 * entry.mochi,
      affection: 2 * entry.mochi,
      bodyValue: 5 * entry.mochi,
      gBalance: -200 * entry.mochi,
    );
    final grassEffect = _WeeklyEffects(
      stress: -50 * entry.grass,
      fear: 2 * entry.grass,
      bodyValue: -5 * entry.grass,
      gBalance: -200 * entry.grass,
    );
    return mangoEffect + mochiEffect + grassEffect;
  }

  int _conditionValue(int fatigue, int stress) {
    return _floorDiv(fatigue, 20) + _floorDiv(stress, 10);
  }

  int _lifeCostFromCondition(int condition) {
    if (condition <= 3) {
      return 1;
    }
    return ((condition - 4) ~/ 2) + 2;
  }

  int _calculateLoyalty(int previousLoyalty, int affection, int fear) {
    final delta = _floorDiv(affection - fear, 15);
    final next = previousLoyalty + delta;
    if (next < 0) {
      return 0;
    }
    if (next > 100) {
      return 100;
    }
    return next;
  }

  int _clampNonNegative(int value) {
    return math.max(0, value);
  }
  int _clampValidValue(int value, int lower, int higher) {
    return math.min(higher, math.max(lower, value));
  }

  int _floorDiv(int dividend, int divisor) {
    if (divisor == 0) {
      throw ArgumentError.value(divisor, 'divisor', 'Cannot be zero');
    }
    final quotient = dividend ~/ divisor;
    final hasRemainder = dividend % divisor != 0;
    if (dividend < 0 && hasRemainder) {
      return quotient - 1;
    }
    return quotient;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedSidebarIndex = index;
    });
  }

  void _onDrawerDestinationSelected(int index) {
    _onDestinationSelected(index);
    Navigator.of(context).pop();
  }

  Widget _buildContent() {
    switch (_selectedSidebarIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('Top row')),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('You have pushed the button this many times:'),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('Bottom row')),
                ),
              ),
            ],
          ),
        );
      case 1:
        return _buildHistoryPage();
      case 2:
        return const Center(child: Text('設定画面は現在準備中です'));
      case 3:
        return _buildDebugHistoryPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHistoryPage() {
    return _buildHistoryTable(
      _filteredHistoryColumns((column) => column.visibleInStandard),
    );
  }

  Widget _buildDebugHistoryPage() {
    return _buildHistoryTable(_filteredHistoryColumns((_) => true));
  }

  Widget _buildHistoryTable(List<_HistoryColumn> columns) {
    if (_historyEntries.isEmpty) {
      return const Center(child: Text('モンスターの履歴データがありません'));
    }

    final histories = _recalculateHistoryEntries();
    final theme = Theme.of(context);

    final rows = <DataRow>[];
    for (var i = 0; i < histories.length; i++) {
      final history = histories[i];
      rows.add(
        DataRow(
          color: MaterialStateProperty.resolveWith(
            (states) => i.isEven
                ? theme.colorScheme.surfaceVariant.withOpacity(0.25)
                : null,
          ),
          cells: [
            for (final column in columns)
              DataCell(column.cellBuilder(history)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              theme.colorScheme.primaryContainer.withOpacity(0.35),
            ),
            columnSpacing: 16,
            border: TableBorder.all(
              color: theme.dividerColor,
              width: 0.5,
            ),
            columns: [
              for (final column in columns)
                DataColumn(
                  label: Text(column.label),
                  numeric: column.isNumeric,
                ),
            ],
            rows: rows,
          ),
        ),
      ),
    );
  }


  String _formatPeriod(MonsterHistory history) {
    return '${history.year}/ ${history.month}/ ${history.week}';
  }

  String _formatAge(MonsterHistory history) {
    final parts = <String>[];
    parts.add('${history.ageYears}/');
    parts.add('${history.ageMonths}/');
    parts.add('${history.ageWeeks}');
    return parts.join();
  }

  String _actionLabel(MonsterAction action) {
    switch (action) {
      case MonsterAction.none:
        return 'なし';
      case MonsterAction.lightWork:
        return '軽仕事';
      case MonsterAction.heavyWork:
        return '重仕事';
      case MonsterAction.training:
        return '修行';
      case MonsterAction.rest:
        return '休養';
      case MonsterAction.tournament:
        return '大会';
      case MonsterAction.expedition:
        return '冒険';
      case MonsterAction.expeditionReturn:
        return '冒険帰還';
      case MonsterAction.hibernation:
        return '冬眠';
    }
  }

  String _bodyTypeLabel(BodyType type) {
    switch (type) {
      case BodyType.normal:
        return '普通';
      case BodyType.big:
        return '太り気味';
      case BodyType.tooBig:
        return 'デブ';
      case BodyType.small:
        return '痩せ気味';
      case BodyType.tooSmall:
        return 'ガリ';
    }
  }

  String _feedLabel(MonsterFeed feed) {
    switch (feed) {
      case MonsterFeed.potato:
        return 'ポテト';
      case MonsterFeed.fish:
        return '魚';
      case MonsterFeed.meat:
        return '肉';
      default:
        return '-';
    }
  }

  List<_HistoryColumn> _filteredHistoryColumns(
    bool Function(_HistoryColumn column) predicate,
  ) {
    return [
      for (final column in _allHistoryColumns())
        if (predicate(column)) column,
    ];
  }

  List<_HistoryColumn> _allHistoryColumns() {
    return [
      _HistoryColumn(
        label: '日付',
        cellBuilder: (history) => Text(_formatPeriod(history)),
      ),
        _HistoryColumn(
        label: '寿命残(週)',
        cellBuilder: (history) => Text(history.lifespan.toString()),
      ),
      _HistoryColumn(
        label: '寿命(%)',
        isNumeric: true,
        cellBuilder: (history) =>
            Text((history.lifespanPercent * 100).toStringAsFixed(1)),
      ),
      _HistoryColumn(
        label: '年齢',
        visibleInStandard: false,
        cellBuilder: (history) => Text(_formatAge(history)),
      ),
      _HistoryColumn(
        label: '体型値',
        visibleInStandard: false,
        cellBuilder: (history) => Text(history.bodyValue.toString()),
      ),
      _HistoryColumn(
        label: '体型',
        visibleInStandard: false,
        cellBuilder: (history) => Text(_bodyTypeLabel(history.bodyType)),
      ),
      _HistoryColumn(
        label: '忠誠',
        isNumeric: true,
        cellBuilder: (history) => Text(history.loyalty.toString()),
      ),
      _HistoryColumn(
        label: '甘え',
        isNumeric: true,
        cellBuilder: (history) => Text(history.affection.toString()),
      ),
      _HistoryColumn(
        label: '恐れ',
        isNumeric: true,
        cellBuilder: (history) => Text(history.fear.toString()),
      ),
      _HistoryColumn(
        label: '疲労',
        isNumeric: true,
        cellBuilder: (history) => Text(history.fatigue.toString()),
      ),
      _HistoryColumn(
        label: 'ストレス',
        isNumeric: true,
        cellBuilder: (history) => Text(history.stress.toString()),
      ),
      _HistoryColumn(
        label: '体調値',
        isNumeric: true,
        cellBuilder: (history) => Text(history.condition.toString()),
      ),
      _HistoryColumn(
        label: 'ストレス増加',
        isNumeric: true,
        cellBuilder: (history) => Text(history.stressGain.toString()),
      ),
      _HistoryColumn(
        label: '寿命消費',
        isNumeric: true,
        cellBuilder: (history) => Text(history.lifeCost.toString()),
      ),
      _HistoryColumn(
        label: '行動',
        cellBuilder: (history) => Text(_actionLabel(history.action)),
      ),
      _HistoryColumn(
        label: '月餌',
        cellBuilder: (history) => Text(_feedLabel(history.monthlyFeed)),
      ),
      _HistoryColumn(
        label: 'マンゴー',
        isNumeric: true,
        cellBuilder: (history) => Text(history.mango.toString()),
      ),
      _HistoryColumn(
        label: '香り餅',
        isNumeric: true,
        cellBuilder: (history) => Text(history.mochi.toString()),
      ),
      _HistoryColumn(
        label: '冬美草',
        isNumeric: true,
        cellBuilder: (history) => Text(history.grass.toString()),
      ),
      _HistoryColumn(
        label: '所持金(G)',
        isNumeric: true,
        cellBuilder: (history) => Text(history.gBalance.toString()),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Monster farm visualizer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('概要'),
                selected: _selectedSidebarIndex == 0,
                onTap: () => _onDrawerDestinationSelected(0),
              ),
              ListTile(
                leading: const Icon(Icons.auto_stories),
                title: const Text('履歴'),
                selected: _selectedSidebarIndex == 1,
                onTap: () => _onDrawerDestinationSelected(1),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('設定'),
                selected: _selectedSidebarIndex == 2,
                onTap: () => _onDrawerDestinationSelected(2),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('表debug'),
                selected: _selectedSidebarIndex == 3,
                onTap: () => _onDrawerDestinationSelected(3),
              ),
            ],
          ),
        ),
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

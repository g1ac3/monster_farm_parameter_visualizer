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
  });

  final String label;
  final bool isNumeric;
  final Widget Function(MonsterHistory history) cellBuilder;
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
      bodyType: BodyType.small,
      condition: 78,
      lifeCost: 3,
      action: MonsterAction.training,
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
      bodyType: BodyType.big,
      condition: 92,
      lifeCost: 1,
      action: MonsterAction.rest,
      monthlyFeed: MonsterFeed.meat,
      mango: 0,
      mochi: 0,
      grass: 2,
      gBalance: 580,
    ),
  ];

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
    return _buildHistoryTable(_historyColumns());
  }

  Widget _buildDebugHistoryPage() {
    return _buildHistoryTable(_debugHistoryColumns());
  }

  Widget _buildHistoryTable(List<_HistoryColumn> columns) {
    if (_historyEntries.isEmpty) {
      return const Center(child: Text('モンスターの履歴データがありません'));
    }

    final theme = Theme.of(context);

    final rows = <DataRow>[];
    for (var i = 0; i < _historyEntries.length; i++) {
      final history = _historyEntries[i];
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
      case MonsterAction.expeditionStart:
        return '冒険出発';
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
      case BodyType.small:
        return '痩せ気味';
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
    }
  }

  String _snackSummary(MonsterHistory history) {
    final snacks = <String>[];
    if (history.mango > 0) {
      snacks.add('マンゴー x${history.mango}');
    }
    if (history.mochi > 0) {
      snacks.add('モッチー饅頭 x${history.mochi}');
    }
    if (history.grass > 0) {
      snacks.add('香草 x${history.grass}');
    }
    return snacks.isEmpty ? '-' : snacks.join(' / ');
  }

  List<_HistoryColumn> _historyColumns() {
    return [
      _HistoryColumn(
        label: '日付',
        cellBuilder: (history) => Text(_formatPeriod(history)),
      ),
      _HistoryColumn(
        label: '行動',
        cellBuilder: (history) => Text(_actionLabel(history.action)),
      ),
      _HistoryColumn(
        label: '体調',
        isNumeric: true,
        cellBuilder: (history) => Text(history.condition.toString()),
      ),
      _HistoryColumn(
        label: '忠誠',
        isNumeric: true,
        cellBuilder: (history) => Text(history.loyalty.toString()),
      ),
      _HistoryColumn(
        label: '愛情',
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
        label: 'ストレス増加',
        isNumeric: true,
        cellBuilder: (history) => Text(history.stressGain.toString()),
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
        label: '命の消費',
        isNumeric: true,
        cellBuilder: (history) => Text(history.lifeCost.toString()),
      ),
      _HistoryColumn(
        label: '月例餌',
        cellBuilder: (history) => Text(_feedLabel(history.monthlyFeed)),
      ),
      _HistoryColumn(
        label: 'おやつ',
        cellBuilder: (history) => Text(_snackSummary(history)),
      ),
      _HistoryColumn(
        label: '所持金(G)',
        isNumeric: true,
        cellBuilder: (history) => Text(history.gBalance.toString()),
      ),
    ];
  }

  List<_HistoryColumn> _debugHistoryColumns() {
    return [
      _HistoryColumn(
        label: '日付',
        cellBuilder: (history) => Text(_formatPeriod(history)),
      ),
      _HistoryColumn(
        label: '年齢',
        cellBuilder: (history) => Text(_formatAge(history)),
      ),
      _HistoryColumn(
        label: '行動',
        cellBuilder: (history) => Text(_actionLabel(history.action)),
      ),
      _HistoryColumn(
        label: '体調',
        isNumeric: true,
        cellBuilder: (history) => Text(history.condition.toString()),
      ),
      _HistoryColumn(
        label: 'ボディタイプ',
        cellBuilder: (history) => Text(_bodyTypeLabel(history.bodyType)),
      ),
      _HistoryColumn(
        label: '忠誠',
        isNumeric: true,
        cellBuilder: (history) => Text(history.loyalty.toString()),
      ),
      _HistoryColumn(
        label: '愛情',
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
        label: 'ストレス増加',
        isNumeric: true,
        cellBuilder: (history) => Text(history.stressGain.toString()),
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
        label: '命の消費',
        isNumeric: true,
        cellBuilder: (history) => Text(history.lifeCost.toString()),
      ),
      _HistoryColumn(
        label: '月例餌',
        cellBuilder: (history) => Text(_feedLabel(history.monthlyFeed)),
      ),
      _HistoryColumn(
        label: 'おやつ',
        cellBuilder: (history) => Text(_snackSummary(history)),
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

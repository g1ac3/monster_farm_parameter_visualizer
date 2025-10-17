import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Monster extends HiveObject { //Note: Member variables are not finalized yet.
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  HiveList<MonsterHistory>? history;

  Monster({required this.name, required this.type});
}

@HiveType(typeId: 2)
enum MonsterAction {
  @HiveField(0)
  none,

  @HiveField(1)
  lightWork,

  @HiveField(2)
  heavyWork,

  @HiveField(3)
  training,

  @HiveField(4)
  rest,

  @HiveField(5)
  tournament,

  @HiveField(6)
  expeditionStart,

  @HiveField(7)
  expeditionReturn,

  @HiveField(8)
  hibernation,
}

@HiveType(typeId: 3)
enum MonsterFeed {
  @HiveField(0)
  potato,

  @HiveField(1)
  fish,

  @HiveField(2)
  meat,
}

@HiveType(typeId: 1)
class MonsterHistory extends HiveObject {
  @HiveField(0)
  int year;

  @HiveField(1)
  int month;

  @HiveField(2)
  int week;

  @HiveField(3)
  int lifespan;

  @HiveField(4)
  double lifespanPercent;

  @HiveField(5)
  int ageYears;

  @HiveField(6)
  int ageMonths;

  @HiveField(7)
  int ageWeeks;

  @HiveField(8)
  int fatigue;

  @HiveField(9)
  int stress;

  @HiveField(10)
  int affection;

  @HiveField(11)
  int fear;

  @HiveField(12)
  int loyalty;

  @HiveField(13)
  int stressGain;

  @HiveField(14)
  String bodyType;

  @HiveField(15)
  int condition;

  @HiveField(16)
  int lifeCost;

  @HiveField(17)
  MonsterAction action;

  @HiveField(18)
  MonsterFeed monthlyFeed;

  @HiveField(19)
  int mango;

  @HiveField(20)
  int mochi;

  @HiveField(21)
  int grass;

  @HiveField(22)
  int gBalance;

  MonsterHistory({
    required this.year,
    required this.month,
    required this.week,
    required this.lifespan,
    required this.lifespanPercent,
    required this.ageYears,
    required this.ageMonths,
    required this.ageWeeks,
    required this.fatigue,
    required this.stress,
    required this.affection,
    required this.fear,
    required this.loyalty,
    required this.stressGain,
    required this.bodyType,
    required this.condition,
    required this.lifeCost,
    required this.action,
    required this.monthlyFeed,
    required this.mango,
    required this.mochi,
    required this.grass,
    required this.gBalance,
  });
}

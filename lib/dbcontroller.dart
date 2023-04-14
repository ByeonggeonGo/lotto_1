import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'api_client.dart';
import 'sampler.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class DbController extends GetxController {
  final _boxName = 'episodes';

  static DateTime startDate = DateTime(2002, 12, 8);
  static DateTime today = DateTime.now();

  static int daysSinceStart = today.difference(startDate).inDays;
  static int eventPeriod = 7;
  int eventCount = (daysSinceStart / eventPeriod).ceil();

  RxList numbersList = [].obs;
  RxList prednumbersList = [].obs;
  RxInt count = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    final box = await Hive.openBox(_boxName);

    final episodes = box.get('episodes', defaultValue: []);
    int counthist = box.get('count', defaultValue: 5);
    DateTime date = box.get('date', defaultValue: today);
    List prednum = box.get('prednum', defaultValue: []);

    count.value = counthist;

    // 날짜 확인해서 5개 충전해주는부분
    if (date != today) {
      await box.put('count', 5);
      await box.put('date', today);

      count.value = 5;
    } else {}

    prednumbersList.value = prednum;
    numbersList.value = episodes;
  }

  Future<void> fetchWinningNumbers(int round) async {
    final apiClient = ApiClient();
    await apiClient.fetchWinningNumbers(round);

    final box = await Hive.openBox(_boxName);
    final episodes = box.get('episodes', defaultValue: []);
    numbersList.value = episodes;
  }

  checkDBnUpdate() async {
    final box = await Hive.openBox(_boxName);
    final episodes = box.get('episodes', defaultValue: []);

    if (episodes.length != eventCount || episodes[0][0] != eventCount) {
      String numbersString = await rootBundle.loadString('assets/numbers.csv');
      List<List<dynamic>> rows =
          const CsvToListConverter().convert(numbersString);

      await box.put('episodes', rows.sublist(1));
      final episodes = box.get('episodes', defaultValue: []);

      for (int i = episodes.length + 1; i <= eventCount; i++) {
        await Future.delayed(Duration(milliseconds: 30));
        fetchWinningNumbers(i);
      }

      final updated_episodes = box.get('episodes', defaultValue: []);

      updated_episodes.sort((a, b) => b[0].compareTo(a[0]) as int);
      await box.put('episodes', updated_episodes);
      numbersList.value = updated_episodes;
    }
  }

  useCount(int usecount) async {
    final box = await Hive.openBox(_boxName);
    final counthist = box.get('count', defaultValue: 5);

    count.value = counthist - usecount;

    await box.put('count', count.value);
  }

  getprednum(int usecount) async {
    final box = await Hive.openBox(_boxName);
    List predsamnum =
        Sampler().sample_nums(numbersList, usecount, [1, 2, 3, 4, 5, 6, 7]);

    prednumbersList.value.insertAll(0, predsamnum);
    // 리스트 정보는 100개까지만 저장
    if (prednumbersList.value.length > 100) {
      prednumbersList.value = prednumbersList.value.sublist(0, 100);
    }

    await box.put('prednum', prednumbersList.value);
  }
}

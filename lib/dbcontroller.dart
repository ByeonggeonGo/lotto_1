import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'api_client.dart';

class DbController extends GetxController {
  final _boxName = 'episodes';

  static DateTime startDate = DateTime(2002, 12, 8);
  static DateTime today = DateTime.now();

  static int daysSinceStart = today.difference(startDate).inDays;
  static int eventPeriod = 7;
  int eventCount = (daysSinceStart / eventPeriod).ceil();

  RxList numbersList = [].obs;
  RxInt count = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    final box = await Hive.openBox(_boxName);

    final episodes = box.get('episodes', defaultValue: []);
    int counthist = box.get('count', defaultValue: 5);
    DateTime date = box.get('date', defaultValue: today);

    count.value = counthist;

    if (date != today) {
      await box.put('count', 5);
      await box.put('date', today);

      count.value = 5;
    } else {}

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

    if (episodes.length != eventCount) {
      for (int i = episodes.length + 1; i <= eventCount; i++) {
        print(i);
        await Future.delayed(Duration(milliseconds: 30));
        fetchWinningNumbers(i);
      }
    }
  }

  useCount(int usecount) async {
    final box = await Hive.openBox(_boxName);
    final counthist = box.get('count', defaultValue: 5);

    count.value = counthist - usecount;

    await box.put('count', count.value);
  }
}

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'api_client.dart';

class DbController extends GetxController {
  final _boxName = 'episodes';

  static DateTime startDate = DateTime(2002, 12, 7);
  static DateTime today = DateTime.now();

  static int daysSinceStart = today.difference(startDate).inDays;
  static int eventPeriod = 7;
  int eventCount = (daysSinceStart / eventPeriod).ceil();

  RxList numbersList = [].obs;

  @override
  void onInit() async {
    super.onInit();
    final box = await Hive.openBox(_boxName);
    final episodes = box.get('episodes', defaultValue: []);
    numbersList.value = episodes;
  }

  Future<void> fetchWinningNumbers(int round) async {
    final apiClient = ApiClient();
    await apiClient.fetchWinningNumbers(round);

    final box = await Hive.openBox(_boxName);
    final episodes = box.get('episodes', defaultValue: []);
    numbersList.value = episodes;
  }
}

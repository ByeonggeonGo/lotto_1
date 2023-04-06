import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'network_check.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiClient extends GetConnect {
  final _boxName = 'episodes';
  NetworkChecker netchecker = Get.find();

  Future<void> fetchWinningNumbers(int round) async {
    final url =
        'https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=$round';

    final response = await get(url).timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      //
      List numlist = [
        jsonData['drwNo'],
        jsonData['drwtNo1'],
        jsonData['drwtNo2'],
        jsonData['drwtNo3'],
        jsonData['drwtNo4'],
        jsonData['drwtNo5'],
        jsonData['drwtNo6'],
        jsonData['bnusNo'],
        jsonData['firstWinamnt'],
        jsonData['firstPrzwnerCo'],
      ];

      final box = await Hive.openBox(_boxName);
      final episodes = box.get('episodes', defaultValue: []);
      episodes.insert(0, numlist);
      await box.put('episodes', episodes);
    } else {
      netchecker.setnewstate(ConnectivityResult.none);
      // throw Exception('Failed to load winning numbers');
    }
  }
}

import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ApiClient extends GetConnect {
  // static const baseUrl = 'https://www.dhlottery.co.kr/common.do';
  // Map<String, Map<String, dynamic>> _lottoList = {};
  // Map<String, Map<String, dynamic>> get lottoList => _lottoList;
  final _boxName = 'episodes';

  Future<void> fetchWinningNumbers(int round) async {
    final url =
        'https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=$round';

    final response = await get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      //
      Map<String, dynamic> lottoData = {
        'round': jsonData['drwNo'],
        'date': jsonData['drwNoDate'],
        'num1': jsonData['drwtNo1'],
        'num2': jsonData['drwtNo2'],
        'num3': jsonData['drwtNo3'],
        'num4': jsonData['drwtNo4'],
        'num5': jsonData['drwtNo5'],
        'num6': jsonData['drwtNo6'],
        'bonus': jsonData['bnusNo'],
      };
      final box = await Hive.openBox(_boxName);
      final episodes = box.get('episodes', defaultValue: []);
      episodes.add(lottoData);
      await box.put('episodes', episodes);
    } else {
      throw Exception('Failed to load winning numbers');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class LottoApiClient {
  static const baseUrl = 'https://www.dhlottery.co.kr/common.do';

  Future<Map<String, dynamic>> fetchWinningNumbers(int round) async {
    final url = '$baseUrl?method=getLottoNumber&drwNo=$round';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load winning numbers');
    }
  }
}

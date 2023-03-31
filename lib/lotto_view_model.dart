import 'package:flutter/material.dart';
import 'lotto_api_client.dart';
import 'lotto_numbers.dart';

class LottoViewModel extends ChangeNotifier {
  final _apiClient = LottoApiClient();
  LottoNumbers? _winningNumbers;

  Future<void> fetchWinningNumbers(int round) async {
    try {
      final data = await _apiClient.fetchWinningNumbers(round);
      _winningNumbers = LottoNumbers.fromJson(data);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  List<int> get numbers => _winningNumbers?.numbers ?? [];
  int get bonusNumber => _winningNumbers?.bonusNumber ?? 0;
  bool get hasData => _winningNumbers != null;
}

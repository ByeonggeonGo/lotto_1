import 'dart:convert';
import 'package:http/http.dart' as http;

class LottoNumbers {
  final int round;
  final List<int> numbers;
  final int bonusNumber;

  LottoNumbers({
    required this.round,
    required this.numbers,
    required this.bonusNumber,
  });

  factory LottoNumbers.fromJson(Map<String, dynamic> json) {
    final List<int> numbers = [
      json['drwtNo1'],
      json['drwtNo2'],
      json['drwtNo3'],
      json['drwtNo4'],
      json['drwtNo5'],
      json['drwtNo6'],
    ];

    return LottoNumbers(
      round: json['drwNo'],
      numbers: numbers,
      bonusNumber: json['bnusNo'],
    );
  }
}

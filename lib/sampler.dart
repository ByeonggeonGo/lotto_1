import 'dart:math';
import 'package:hive/hive.dart';

class Sampler {
  sample_nums(List numlist, int sam_num, List colind) {
    // List<int> indexs = [];
    int list_len = numlist.length;
    List results = [];

    for (int i = 0; i < sam_num; i++) {
      List sub_list = [];
      for (int j = 0; j < colind.length; j++) {
        int randomIndex = Random().nextInt(list_len);

        sub_list.add(numlist[randomIndex][colind[j]]);
      }
      results.add(sub_list);
    }
    return results;
  }
}

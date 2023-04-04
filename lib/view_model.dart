import 'package:get/get.dart';
import 'dbcontroller.dart';

class ViewModel extends GetxController {
  final DbController _repository = Get.put(DbController());
  RxList numbersList = [].obs;

  @override
  void onInit() {
    super.onInit();
    numbersList.bindStream(_repository.numbersList.stream);
    _repository.onInit();

    debounce(numbersList, (_) => print("debounce"), time: Duration(seconds: 5));
  }

  Future<void> fetchWinningNumbers(int round) async {
    await _repository.fetchWinningNumbers(round);
    numbersList.refresh();
    print(numbersList.last);
  }
}

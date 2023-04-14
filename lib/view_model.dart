import 'package:get/get.dart';
import 'dbcontroller.dart';

class ViewModel extends GetxController {
  final DbController _repository = Get.put(DbController());
  RxList numbersList = [].obs;
  RxInt count = 0.obs;
  RxInt agree_ind = 0.obs;

  @override
  void onInit() {
    super.onInit();
    numbersList.bindStream(_repository.numbersList.stream);
    count.bindStream(_repository.count.stream);
    _repository.onInit();

    // interval(numbersList, (_) => print(numbersList.length),
    //     time: Duration(seconds: 3));
  }

  Future<void> fetchWinningNumbers(int round) async {
    await _repository.fetchWinningNumbers(round);
    numbersList.refresh();
  }

  Future<void> checkDBnUpdate() async {
    await _repository.checkDBnUpdate();
    numbersList.refresh();
  }

  Future<void> useCount(int usecount) async {
    await _repository.useCount(usecount);
    count.refresh();
  }
}

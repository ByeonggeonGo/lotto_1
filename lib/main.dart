import 'package:flutter/material.dart';
import 'view_model.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle, SystemNavigator;
import 'package:csv/csv.dart';
import 'widlist_model.dart';
import 'network_check.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sampler.dart';

// round,num1,num2,num3,num4,num5,num6,bonus,firstWinamnt,firstPrzwnerCo
void main() async {
  var path = Directory.current.path;
  // Hive..init(path);
  await Hive.initFlutter();

  final box = await Hive.openBox('episodes');
  // await box.put('episodes', []); // 이부분 테스트중이라 넣어놓은 것 실제로할때는 빼기
  // // await box.put('date', DateTime(2023, 4, 5)); // ㅇ이부분ㅗ 테트ㅇ 날ㅏ 바끼ㄴㅓㅅ

  final episodes = box.get('episodes', defaultValue: []);

  if (episodes.length == 0) {
    String numbersString = await rootBundle.loadString('assets/numbers.csv');
    List<List<dynamic>> rows =
        const CsvToListConverter().convert(numbersString);

    await box.put('episodes', rows.sublist(1));

    final episodes = box.get('episodes', defaultValue: []);
    print(episodes.length);
  }

  ViewModel viewmodel = Get.put(ViewModel());
  NumberwidsList numwidslist = Get.put(NumberwidsList());
  NetworkChecker netchecker = Get.put(NetworkChecker());

  await netchecker.updateConnectionStatus();

  print(netchecker.connectionStatus);
  netchecker.connectionStatus != ConnectivityResult.none
      ? viewmodel.checkDBnUpdate()
      : print('network 확인');

  runApp(GetMaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ViewModel viewmodel = Get.find();

    return HomePage();
  }
}

class HomePage extends StatelessWidget {
  TextEditingController myController = TextEditingController();
  ViewModel viewmodel = Get.find();
  NumberwidsList numwidslist = Get.find();
  NetworkChecker netchecker = Get.find();

  @override
  Widget build(BuildContext context) {
    // netchecker.networkcheck();

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text('Demo'),
          Obx(() => Text(viewmodel.count.toString()))
        ]),
      ),
      body: Column(
        children: [
          netchecker.connectionStatus != ConnectivityResult.none
              ? Flexible(
                  // height: Get.height * 0.6,
                  // width: Get.width * 0.9,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Obx(() => numwidslist.numbersList.length ==
                                numwidslist.repository.eventCount
                            ? numwidslist.numTable
                            : Text('최신회차정보 업데이트중 --' +
                                numwidslist.numbersList.length.toString()))),
                  ),
                )
              : Text('네트워크 상태를 확인하세요.'),
          FloatingActionButton(onPressed: () async {
            // Get.dialog(
            //   AlertDialog(
            //     title: Text("네트워크 연결을 확인하세요."),
            //     actions: [
            //       ElevatedButton(
            //         onPressed: () {
            //           SystemNavigator.pop(); // 앱 종료
            //         },
            //         child: Text("확인"),
            //       ),
            //     ],
            //   ),
            //   barrierDismissible: false, // 다이얼로그 외부 클릭 시 종료
            // );
            viewmodel.useCount(1);
            print(viewmodel.numbersList.length);
            print(Sampler()
                .sample_nums(viewmodel.numbersList, 10, [1, 2, 3, 4, 5, 6, 7]));

            if (ConnectivityResult.wifi == netchecker.connectionStatus.value) {
              print('wifi');
            } else {
              print(netchecker.connectionStatus.value);
            }
          }),
          Container(
            height: 100,
          )
        ],
      ),
    );
  }
}

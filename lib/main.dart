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
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

const int maxFailedLoadAttempts = 3;

const Map<String, String> UNIT_ID = kReleaseMode
    ? {
        'ios': '[YOUR iOS AD UNIT ID]',
        'android': 'ca-app-pub-5666990059725232/7650613863',
      }
    : {
        'ios': 'ca-app-pub-3940256099942544/2934735716',
        'android': 'ca-app-pub-3940256099942544/6300978111',
      };

const Map<String, String> UNIT_ID_2 = kReleaseMode
    ? {
        'ios': '[YOUR iOS AD UNIT ID]',
        'android': 'ca-app-pub-5666990059725232/4950414437',
      }
    : {
        'ios': 'ca-app-pub-3940256099942544/2934735716',
        'android': 'ca-app-pub-3940256099942544/6300978111',
      };

// round,num1,num2,num3,num4,num5,num6,bonus,firstWinamnt,firstPrzwnerCo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  var path = Directory.current.path;
  await Hive.initFlutter();

  final box = await Hive.openBox('episodes');
  // await box.put('episodes', []); // 이부분 테스트중이라 넣어놓은 것 실제로할때는 빼기
  // await box.put('date', DateTime(2023, 4, 5)); // ㅇ이부분ㅗ 테트ㅇ 날ㅏ 바끼ㄴㅓㅅ

  final episodes = box.get('episodes', defaultValue: []);

  if (episodes.length == 0) {
    String numbersString = await rootBundle.loadString('assets/numbers.csv');
    List<List<dynamic>> rows =
        const CsvToListConverter().convert(numbersString);

    await box.put('episodes', rows.sublist(1));

    final episodes = box.get('episodes', defaultValue: []);
  }

  ViewModel viewmodel = Get.put(ViewModel());
  NumberwidsList numwidslist = Get.put(NumberwidsList());
  NetworkChecker netchecker = Get.put(NetworkChecker());

  await netchecker.updateConnectionStatus();

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
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  _createRewardedAd() {
    RewardedAd.load(
        adUnitId: UNIT_ID_2['android']!,
        // adUnitId: 'ca-app-pub-5666990059725232/4950414437',
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      numwidslist.getprednum(reward.amount.toInt());

      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }

  @override
  Widget build(BuildContext context) {
    // netchecker.networkcheck();
    TargetPlatform os = Theme.of(context).platform;
    BannerAd banner = BannerAd(
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {},
        onAdLoaded: (_) {},
      ),
      size: AdSize.banner,
      adUnitId: UNIT_ID[os == TargetPlatform.iOS ? 'ios' : 'android']!,
      request: AdRequest(),
    )..load();

    return Scaffold(
      appBar: AppBar(
        title: Text('최고 로또'),
      ),
      body: Column(
        children: [
          Obx(() => netchecker.connectionStatus.value != ConnectivityResult.none
              ? Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Obx(() => numwidslist.numbersList.length ==
                                numwidslist.repository.eventCount
                            ? numwidslist.tableind.value == 0
                                ? numwidslist.numTable
                                : numwidslist.prednumTable
                            : Text('최신회차정보 업데이트중 --' +
                                numwidslist.numbersList.length.toString()))),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: Text("네트워크 연결을 확인하세요."),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              SystemNavigator.pop(); // 앱 종료
                            },
                            child: Text("확인"),
                          ),
                        ],
                      ),
                      barrierDismissible: false, // 다이얼로그 외부 클릭 시 종료
                    );
                  },
                  child: Text("네트워크 연결 확인"),
                )),
          Obx(() => numwidslist.tableind == 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 1;
                        i <=
                            numwidslist.numbersList.length ~/
                                    numwidslist.tablelen +
                                1;
                        i++)
                      GestureDetector(
                        child: Container(
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: numwidslist.tablepage.value == i
                                  ? Colors.blue.withOpacity(0.2)
                                  : null, // 은은한 파란색으로 색상 설정
                              borderRadius: BorderRadius.circular(
                                  10.0), // 10.0의 반경을 갖는 모서리가 둥근 컨테이너로 설정
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.grey.withOpacity(0.3), // 흰색 그림자 효과
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 2), // y축 방향으로 약간의 그림자 효과 추가
                                ),
                              ],
                            ),
                            child: Text(i.toString())),
                        onTap: () {
                          numwidslist.tablepage.value = i;
                          numwidslist.tableind.value = 0;

                          // numwidslist.updatetable();
                        },
                      )
                  ],
                )
              : Text('뽑은 번호는 200개까지만 저장됩니다.')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () async {
                  await netchecker.updateConnectionStatus();
                  if (netchecker.connectionStatus != ConnectivityResult.none) {
                    if (viewmodel.count.value != 0) {
                      numwidslist.getprednum(viewmodel.count.value);
                      viewmodel.useCount(viewmodel.count.value);
                      numwidslist.tableind.value = 1;
                    } else {
                      Get.dialog(
                        AlertDialog(
                          title: Text("광고보고 20개 뽑기"),
                          content: Text('매일정각마다 5개씩 무료 뽑기횟수가 충전됩니다.'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                                _createRewardedAd();
                                _showRewardedAd();
                              },
                              child: Text("확인"),
                            ),
                          ],
                        ),
                        barrierDismissible: true, // 다이얼로그 외부 클릭 시 종료
                      );
                    }
                  } else {
                    Get.dialog(
                      AlertDialog(
                        title: Text("네트워크 연결을 확인하세요."),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              SystemNavigator.pop(); // 앱 종료
                            },
                            child: Text("확인"),
                          ),
                        ],
                      ),
                      barrierDismissible: false, // 다이얼로그 외부 클릭 시 종료
                    );
                  }
                },
                child: Container(
                  height: 30,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2), // 은은한 파란색으로 색상 설정
                    borderRadius: BorderRadius.circular(
                        10.0), // 10.0의 반경을 갖는 모서리가 둥근 컨테이너로 설정
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // 흰색 그림자 효과
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 2), // y축 방향으로 약간의 그림자 효과 추가
                      ),
                    ],
                  ),
                  child: Obx(() => Text(
                        viewmodel.count.value != 0
                            ? '번호예측(' + viewmodel.count.value.toString() + '개)'
                            : '번호예측(광고)',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      )),
                ),
              ),
              GestureDetector(
                onTap: () {
                  print(viewmodel.agree_ind.value);
                  print(123123123);

                  viewmodel.agree_ind.value == 0
                      ? Get.dialog(
                          AlertDialog(
                            title: Text("주의!"),
                            content: Text(
                                '번호추첨결과는 참고용으로만 사용하세요 당첨을 보장하지 않습니다. 앱 개발자나 운영자가 책임을 지지 않습니다. 번호 추첨 결과를 참고로만 활용하고, 결과에 따른 모든 결정과 행동에 대한 책임은 사용자 본인에게 있습니다.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  viewmodel.agree_ind.value = 1;
                                },
                                child: Text("확인"),
                              ),
                            ],
                          ),
                          barrierDismissible: false, // 다이얼로그 외부 클릭 시 종료
                        )
                      : numwidslist.tableind.value =
                          numwidslist.tableind.value == 0 ? 1 : 0;
                },
                child: Container(
                  height: 30,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2), // 은은한 파란색으로 색상 설정
                    borderRadius: BorderRadius.circular(
                        10.0), // 10.0의 반경을 갖는 모서리가 둥근 컨테이너로 설정
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // 흰색 그림자 효과
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 2), // y축 방향으로 약간의 그림자 효과 추가
                      ),
                    ],
                  ),
                  child: Obx(() => Text(
                        numwidslist.tableind.value == 0 ? '예측번호보기' : '당첨번호보기',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      )),
                ),
              ),
            ],
          ),
          // 1061 ~/ 200

          Container(
              height: 100,
              child: AdWidget(
                ad: banner,
              ))
        ],
      ),
    );
  }
}

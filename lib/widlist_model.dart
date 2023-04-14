import 'package:get/get.dart';
import 'dbcontroller.dart';
import 'package:flutter/material.dart';

class NumberwidsList extends GetxController {
  final DbController _repository = Get.put(DbController());
  get repository => _repository;
  RxList numbersList = [].obs;
  RxList prednumbersList = [].obs;
  RxInt tableind = 0.obs;
  RxInt tablepage = 1.obs;
  int tablelen = 200;

  NumTable numTable = NumTable(
    numlistall: [],
  );

  PredNumTable prednumTable = PredNumTable(
    prednumlistall: [],
  );

  @override
  void onInit() {
    super.onInit();
    numbersList.bindStream(_repository.numbersList.stream);
    prednumbersList.bindStream(_repository.prednumbersList.stream);
    _repository.onInit();

    // numTable = NumTable(
    //   numlistall: numbersList.sublist(
    //       (tablepage.value - 1) * tablelen, tablepage.value * tablelen),
    // );

    prednumTable = PredNumTable(
      prednumlistall: prednumbersList,
    );

    interval(numbersList, (_) => numbersList.refresh());
    interval(numbersList, (_) => updatetable(), time: Duration(seconds: 3));

    interval(prednumbersList, (_) => prednumbersList.refresh());
    interval(prednumbersList, (_) => updatetable(), time: Duration(seconds: 3));
  }

  void updatetable() {
    numTable = NumTable(
      numlistall: numbersList.sublist(
          (tablepage.value - 1) * tablelen, tablepage.value * tablelen),
    );

    prednumTable = PredNumTable(
      prednumlistall: prednumbersList,
    );
  }

  getprednum(int useCount) async {
    await _repository.getprednum(useCount);
    prednumbersList.refresh();
  }
}

class NumTable extends StatelessWidget {
  final List numlistall;

  const NumTable({required this.numlistall});

  @override
  Widget build(BuildContext context) {
    return DataTable(
        dataRowHeight: 16,
        horizontalMargin: 10,
        columnSpacing: 10,
        columns: [
          DataColumn(label: Text('회차')),
          DataColumn(label: Text('1번')),
          DataColumn(label: Text('2번')),
          DataColumn(label: Text('3번')),
          DataColumn(label: Text('4번')),
          DataColumn(label: Text('5번')),
          DataColumn(label: Text('6번')),
          DataColumn(label: Text('보너스')),
          DataColumn(label: Text('1등상금')),
          DataColumn(label: Text('1등당첨수')),
        ],
        rows: [
          for (int i = 0; i < numlistall.length; i++)
            DataRow(cells: [
              for (int j = 0; j < numlistall[i].length; j++)
                DataCell(Text(numlistall[i][j].toString()))
            ])
        ]);
  }
}

class PredNumTable extends StatelessWidget {
  final List prednumlistall;

  const PredNumTable({required this.prednumlistall});

  @override
  Widget build(BuildContext context) {
    return DataTable(
        dataRowHeight: 16,
        horizontalMargin: 10,
        columnSpacing: 10,
        columns: [
          DataColumn(label: Text('1번')),
          DataColumn(label: Text('2번')),
          DataColumn(label: Text('3번')),
          DataColumn(label: Text('4번')),
          DataColumn(label: Text('5번')),
          DataColumn(label: Text('6번')),
          DataColumn(label: Text('보너스')),
        ],
        rows: [
          for (int i = 0; i < prednumlistall.length; i++)
            DataRow(cells: [
              for (int j = 0; j < prednumlistall[i].length; j++)
                DataCell(Text(prednumlistall[i][j].toString()))
            ])
        ]);
  }
}

import 'package:get/get.dart';
import 'dbcontroller.dart';
import 'package:flutter/material.dart';

class NumberwidsList extends GetxController {
  final DbController _repository = Get.put(DbController());
  get repository => _repository;
  RxList numbersList = [].obs;

  NumTable numTable = NumTable(
    numlistall: [],
  );

  @override
  void onInit() {
    super.onInit();
    numbersList.bindStream(_repository.numbersList.stream);
    _repository.onInit();

    numTable = NumTable(
      numlistall: numbersList,
    );

    interval(numbersList, (_) => numbersList.refresh());
    interval(numbersList, (_) => updatetable(), time: Duration(seconds: 1));
  }

  void updatetable() {
    numTable = NumTable(
      numlistall: numbersList,
    );
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
          DataColumn(label: Text('round')),
          DataColumn(label: Text('num1')),
          DataColumn(label: Text('num2')),
          DataColumn(label: Text('num3')),
          DataColumn(label: Text('num4')),
          DataColumn(label: Text('num5')),
          DataColumn(label: Text('num6')),
          DataColumn(label: Text('bonus')),
          DataColumn(label: Text('firstWinamnt')),
          DataColumn(label: Text('firstPrzwnerCo')),
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

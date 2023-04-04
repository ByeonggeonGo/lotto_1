import 'package:flutter/material.dart';
import 'view_model.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

void main() async {
  var path = Directory.current.path;
  // Hive..init(path);
  await Hive.initFlutter();

  runApp(GetMaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ViewModel viewmodel = Get.put(ViewModel());

    return HomePage();
  }
}

class HomePage extends StatelessWidget {
  TextEditingController myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ViewModel viewmodel = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo'),
      ),
      body: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.number,
            controller: myController,
            validator: (value) {
              if (value != null && value.isEmpty) {
                return '값을 입력하세요';
              }
              return null;
            },
            onFieldSubmitted: (value) async {
              int? intValue = int.tryParse(value);
              if (intValue != null) {
                await viewmodel.fetchWinningNumbers(intValue);
              }

              myController.clear();
            },
          ),
          Obx(() => Text(viewmodel.numbersList.length.toString()))
        ],
      ),
    );
  }
}

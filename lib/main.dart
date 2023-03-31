import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lotto_view.dart';
import 'lotto_view_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LottoViewModel(),
      child: MaterialApp(
        title: 'Lotto App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LottoView(),
      ),
    );
  }
}

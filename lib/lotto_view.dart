import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lotto_view_model.dart';

class LottoView extends StatefulWidget {
  @override
  _LottoViewState createState() => _LottoViewState();
}

class _LottoViewState extends State<LottoView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LottoViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lotto Winning Numbers'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter round number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a round number';
                      } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Please enter a valid round number';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final round = int.parse(_controller.text);
                          viewModel.fetchWinningNumbers(round);
                        }
                      },
                      child: Text('Search'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            if (viewModel.hasData)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Winning Numbers:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: viewModel.numbers
                        .map((number) => Container(
                              margin: EdgeInsets.only(right: 8.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Text(
                                  '$number',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Bonus Number:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    margin: EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text(
                        '${viewModel.bonusNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

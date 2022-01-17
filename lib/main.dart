// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

List<int> _barVals = <int>[50, 20, 10, 100, 40, 10, 5];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Relationship Bars',
      home: Bars(),
    );
  }
}

class Bars extends StatefulWidget {
  const Bars({Key? key}) : super(key: key);

  @override
  _BarsState createState() => _BarsState();
}

class _BarsState extends State<Bars> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relationship Bars'),
      ),
      body: _buildBars(),
    );
  }

  Widget _buildBars() {
    return ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _barVals.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (context, index) {
          return (BarSlider(index));
        });
  }
}

class BarSlider extends StatefulWidget {
  final int index;
  const BarSlider(this.index, {Key? key}) : super(key: key);

  @override
  _BarSliderState createState() => _BarSliderState(
    index: this.index,
  );
}

class _BarSliderState extends State<BarSlider> {
  final int index;
  int _sliderValue = 0;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  _BarSliderState({required final this.index});

  @override
  void initState() {
    super.initState();
    _sliderValue = _barVals[index];
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        ListTile(
          title: Text(
            _barVals[index].toString(),
            style: _biggerFont,
          ),
        ),
        ListTile(
          title: Slider(
            value: _sliderValue.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: _sliderValue.toString(),
            onChanged: (double value) {
              setState(() {
                _sliderValue = value.round();
              });
            },
            onChangeEnd: (double value) {
              setState(() {
                _barVals[index] = value.round();
              });
            },
          ),
        ),
      ]),
    );

  }
}

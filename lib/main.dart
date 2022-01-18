// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:relationship_bars/Database/database_helper.dart';
import 'package:relationship_bars/Database/relationship_bar_model.dart';

late DatabaseHandler _handler = DatabaseHandler();

void main() async {
  runApp(const MyApp());
}

/*NOTE SHARED PREFERENCES IS BEST FOR STORING SETTINGS*/
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
      body: FutureBuilder(
        future: _handler.retrieveRelationshipBars(),
        builder: _buildBars,
      ),
      /* TODO: FIX BUTTON SO IT DOESN'T OVERLAP SLIDERS. CHOOSE BETTER ICON (FLOPPY DISK) */
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => /* TODO: SAVE BAR VALUES TO STORAGE, AND UPDATE IN SERVER */ null,
        tooltip: 'Save',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBars(BuildContext context, AsyncSnapshot<List<RelationshipBar>> snapshot) {
      if (snapshot.hasData) {
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemBuilder: (BuildContext context, int index) {
            return BarSlider(
              relationshipBar: snapshot.data![index]
            );
          },
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }
}

class BarSlider extends StatefulWidget {
  final RelationshipBar relationshipBar;

  const BarSlider({Key? key, required this.relationshipBar}) : super(key: key);

  @override
  _BarSliderState createState() => _BarSliderState();
}

class _BarSliderState extends State<BarSlider> {
  int _sliderValue = 0;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.relationshipBar.value;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: [
          ListTile(
            title: Text(
              widget.relationshipBar.toString(),
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
              onChangeEnd: (double value) async {
                int iValue = value.round();
                widget.relationshipBar.value = iValue;
                await _handler.updateRelationshipBar(widget.relationshipBar);
                setState(() {
                  _sliderValue = iValue;
                });
              },
            ),
          ),
        ])
    );
  }
}


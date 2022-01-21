import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';

abstract class BarSlider extends StatefulWidget {
  final RelationshipBar relationshipBar;

  const BarSlider({Key? key, required this.relationshipBar}) : super(key: key);
}

abstract class _BarSliderState extends State<BarSlider> {
  int _sliderValue = 100;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.relationshipBar.value;
  }

  Widget sliderText() {
    return Text(
        widget.relationshipBar.toString(),
        style: _biggerFont,
    );
  }

  Widget slider() {
    return Slider(
        value: _sliderValue.toDouble(),
        min: 0,
        max: 100,
        divisions: 100,
        label: _sliderValue.toString(),
        onChanged: changed,
        onChangeEnd: onChangeEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: [
          ListTile(
            title: sliderText(),
          ),
          ListTile(
            title: slider(),
          )
        ])
    );
  }

  void changed(double value) {}
  void onChangeEnd(double value) {}
}

class InteractableBarSlider extends BarSlider {
  const InteractableBarSlider({Key? key, required relationshipBar}) : super(key: key, relationshipBar: relationshipBar);

  @override
  _InteractableBarSliderState createState() => _InteractableBarSliderState();

}

class _InteractableBarSliderState extends _BarSliderState {
  @override
  void changed(double value) {
    setState(() {
      _sliderValue = value.round();
    });
  }

  @override
  Future<void> onChangeEnd(double value) async {
    int iValue = value.round();
    widget.relationshipBar.setValue(iValue);
    await updateBar(iValue);
  }

  Future<void> updateBar(int value) async {
    setState(() {
      _sliderValue = value;
    });
  }

  @override
  Widget sliderText() {
    return Stack(
        children: [
          super.sliderText(),
          if(widget.relationshipBar.changed) Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                  onPressed: () async => await updateBar(widget.relationshipBar.resetValue()), /* TODO: RESET BAR VALUE WHEN PRESSED */
                  icon: const Icon(Icons.undo)
              )
          )
        ]
    );
  }
}

class NonInteractableBarSlider extends BarSlider {
  const NonInteractableBarSlider({Key? key, required relationshipBar}) : super(key: key, relationshipBar: relationshipBar);

  @override
  _NonInteractableBarSliderState createState() => _NonInteractableBarSliderState();
}

class _NonInteractableBarSliderState extends _BarSliderState {
}
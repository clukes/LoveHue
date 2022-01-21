import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/providers/application_state.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
import 'package:relationship_bars/utils/colors.dart';

abstract class BarSlider extends StatefulWidget {
  final RelationshipBar relationshipBar;

  const BarSlider({Key? key, required this.relationshipBar}) : super(key: key);
}

abstract class _BarSliderState extends State<BarSlider> {
  int _sliderValue = 100;
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  get changed => null;
  get onChangeEnd => null;

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
        child:
        Column(children: [
          ListTile(
            title: sliderText(),
          ),
          ListTile(
            title: slider(),
          )
        ])
    );
  }
}

class InteractableBarSlider extends BarSlider {
  const InteractableBarSlider({Key? key, required relationshipBar}) : super(key: key, relationshipBar: relationshipBar);

  @override
  _InteractableBarSliderState createState() => _InteractableBarSliderState();

}

class _InteractableBarSliderState extends _BarSliderState {
  @override
  get changed => (double value) {
    setState(() {
      _sliderValue = value.round();
    });
  };

  @override
  get onChangeEnd => (double value) {
    int iValue = value.round();
    widget.relationshipBar.setValue(iValue);
    YourBarsState.instance.barChange();
    updateBar(iValue);
  };

  void updateBar(int value)  {
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
                  onPressed: () => updateBar(widget.relationshipBar.resetValue()),
                  icon: const Icon(Icons.undo)
              )
          )
        ]
    );
  }

  @override
  Widget slider() {
    if (YourBarsState.instance.barsReset) {
      _sliderValue = widget.relationshipBar.value;
    }
    return super.slider();
  }

}

class NonInteractableBarSlider extends BarSlider {
  const NonInteractableBarSlider({Key? key, required relationshipBar}) : super(key: key, relationshipBar: relationshipBar);

  @override
  _NonInteractableBarSliderState createState() => _NonInteractableBarSliderState();
}

class _NonInteractableBarSliderState extends _BarSliderState {
  @override
  Widget slider() {
    _sliderValue = widget.relationshipBar.value;
    return super.slider();
  }
}
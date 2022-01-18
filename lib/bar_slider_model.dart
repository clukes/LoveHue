import 'package:flutter/material.dart';
import 'package:relationship_bars/Database/relationship_bar_model.dart';

abstract class BarSlider extends StatefulWidget {
  final RelationshipBar relationshipBar;
  final RelationshipBarRepository barRepo;

  const BarSlider({Key? key, required this.relationshipBar, required this.barRepo}) : super(key: key);
}

abstract class _BarSliderState extends State<BarSlider> {
  int _sliderValue = 100;
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
              onChanged: changed,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ])
    );
  }

  void changed(double value) {}
  void onChangeEnd(double value) {}
}

class InteractableBarSlider extends BarSlider {
  const InteractableBarSlider({Key? key, required relationshipBar, required barRepo}) : super(key: key, relationshipBar: relationshipBar, barRepo: barRepo);

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
    widget.relationshipBar.value = iValue;
    await widget.barRepo.update(widget.relationshipBar);
    setState(() {
      _sliderValue = iValue;
    });
  }

}

class NonInteractableBarSlider extends BarSlider {
  const NonInteractableBarSlider({Key? key, required relationshipBar, required barRepo}) : super(key: key, relationshipBar: relationshipBar, barRepo: barRepo);

  @override
  _NonInteractableBarSliderState createState() => _NonInteractableBarSliderState();
}

class _NonInteractableBarSliderState extends _BarSliderState {
}
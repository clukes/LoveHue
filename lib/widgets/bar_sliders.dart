import 'package:flutter/material.dart';
import 'package:relationship_bars/models/relationship_bar_model.dart';
import 'package:relationship_bars/providers/your_bars_state.dart';
import 'package:relationship_bars/utils/colors.dart';

abstract class BarSlider extends StatefulWidget {
  final RelationshipBar relationshipBar;

  const BarSlider({Key? key, required this.relationshipBar}) : super(key: key);
}

abstract class _BarSliderState extends State<BarSlider> {
  int _sliderValue = 100;

  get changed => null;
  get onChangeEnd => null;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.relationshipBar.value;
  }

  Widget sliderText() {
    double fontSize = 14;
    return Row(children: [
      Expanded(
          child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          widget.relationshipBar.labelString(),
          style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: fontSize),
        ),
      )),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Text(
          widget.relationshipBar.valueString(),
          style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: fontSize),
        ),
      ),
    ]);
  }

  Widget slider() {
    final activeTrackColor = getSliderColor(_sliderValue)?.active;
    final inactiveTrackColor = getSliderColor(_sliderValue)?.inactive;
    const disabledOpacityRatio = 0.75;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeTrackColor,
        inactiveTrackColor: inactiveTrackColor,
        disabledActiveTrackColor: activeTrackColor?.withOpacity(activeTrackColor.opacity * disabledOpacityRatio),
        disabledInactiveTrackColor: inactiveTrackColor?.withOpacity(inactiveTrackColor.opacity * disabledOpacityRatio),
      ),
      child: Slider(
        value: _sliderValue.toDouble(),
        min: 0,
        max: 100,
        divisions: 100,
        label: _sliderValue.toString(),
        onChanged: changed,
        onChangeEnd: onChangeEnd,
      ),
    );
  }

  Widget tile() {
    const contentPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 24);
    return ListTile(
      contentPadding: contentPadding,
      title: Padding(padding: const EdgeInsets.only(bottom: 16, right: 16), child: sliderText()),
      subtitle: slider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cardMargin = EdgeInsets.symmetric(vertical: 4, horizontal: 16);
    return Card(
        margin: cardMargin,
        color: Colors.transparent,
        elevation: 0,
        child: Container(
            decoration: const BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(64, 0, 0, 0),
                  blurRadius: 5.0,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
            child: tile()));
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

  void updateBar(int value) {
    setState(() {
      _sliderValue = value;
    });
  }

  @override
  Widget tile() {
    return Stack(
      children: [
        super.tile(),
        if (widget.relationshipBar.changed)
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              onPressed: () => updateBar(widget.relationshipBar.resetValue()),
              icon: const Icon(Icons.replay),
              color: primaryTextColor,
            ),
          )
      ],
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
  const NonInteractableBarSlider({Key? key, required relationshipBar})
      : super(key: key, relationshipBar: relationshipBar);

  @override
  _NonInteractableBarSliderState createState() => _NonInteractableBarSliderState();
}

class _NonInteractableBarSliderState extends _BarSliderState {
  @override
  Widget slider() {
    _sliderValue = widget.relationshipBar.value;
    return super.slider();
  }

  /* TODO: When history is implemented, possibly display the previous bar values on partners screen?
  @override
  Widget sliderText() {
    int prevValue = widget.relationshipBar.prevValue;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
      Expanded(child: super.sliderText()),
      if (_sliderValue != prevValue)
        Text("(Previous: $prevValue)", textAlign: TextAlign.center,),
      const Spacer()
    ]);
  }
  */
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/relationship_bar_model.dart';
import '../providers/user_info_state.dart';
import '../utils/colors.dart';

/// Builds a [Card] for a [RelationshipBar].
abstract class BarSlider extends StatefulWidget {
  final RelationshipBar relationshipBar;

  const BarSlider({Key? key, required this.relationshipBar}) : super(key: key);
}

abstract class _BarSliderState extends State<BarSlider> {
  final double _sliderTextFontSize = 14.0;

  // Ratio of how much less opacity a disabled bar has.
  final double _disabledOpacityRatio = 0.75;

  int _sliderValue = RelationshipBar.defaultBarValue;

  /// Function to call when slider value is changed. Default to null for disabled slider.
  void Function(double)? get changed => null;

  /// Function to call when slider value is finished changing. Default to null for disabled slider.
  void Function(double)? get onChangeEnd => null;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.relationshipBar.value;
  }

  Widget sliderText() {
    return Row(children: [
      Expanded(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            widget.relationshipBar.labelString(),
            style: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: _sliderTextFontSize),
          ),
        ),
      ),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Text(
          widget.relationshipBar.valueString(),
          style: Theme.of(context).textTheme.subtitle2?.copyWith(fontSize: _sliderTextFontSize),
        ),
      ),
    ]);
  }

  Widget slider() {
    // Get slider color based on current value.
    final activeTrackColor = getSliderColor(_sliderValue)?.active;
    final inactiveTrackColor = getSliderColor(_sliderValue)?.inactive;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeTrackColor,
        inactiveTrackColor: inactiveTrackColor,
        disabledActiveTrackColor: activeTrackColor?.withOpacity(activeTrackColor.opacity * _disabledOpacityRatio),
        disabledInactiveTrackColor: inactiveTrackColor?.withOpacity(inactiveTrackColor.opacity * _disabledOpacityRatio),
      ),
      child: Slider(
        value: _sliderValue.toDouble(),
        min: RelationshipBar.minBarValue.toDouble(),
        max: RelationshipBar.maxBarValue.toDouble(),
        // Don't want to have decimals so divisions = range of ints.
        divisions: RelationshipBar.maxBarValue - RelationshipBar.minBarValue,
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
      // Padding on the bottom and right of slider text, to space it from slider and undo button.
      title: Padding(padding: const EdgeInsets.only(bottom: 16, right: 16), child: sliderText()),
      subtitle: slider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cardMargin = EdgeInsets.symmetric(vertical: 4, horizontal: 16);
    return Card(
      margin: cardMargin,
      // Make it transparent since we are adding a container with a gradient.
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 5.0,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: tile(),
      ),
    );
  }
}

/// A [BarSlider] that is not disabled.
class InteractableBarSlider extends BarSlider {
  const InteractableBarSlider({Key? key, required relationshipBar}) : super(key: key, relationshipBar: relationshipBar);

  @override
  _InteractableBarSliderState createState() => _InteractableBarSliderState();
}

class _InteractableBarSliderState extends _BarSliderState {
  @override
  void Function(double)? get changed => (double value) {
        updateBar(value.round());
      };

  @override
  void Function(double)? get onChangeEnd => (double value) {
        int iValue = value.round();
        widget.relationshipBar.setValue(iValue);
        Provider.of<UserInfoState>(context, listen: false).barChange();
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
          // Add undo button if changed, in the top right corner of the card.
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
    if (Provider.of<UserInfoState>(context, listen: false).barsReset) {
      _sliderValue = widget.relationshipBar.value;
    }
    return super.slider();
  }
}

/// A [BarSlider] that is disabled.
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

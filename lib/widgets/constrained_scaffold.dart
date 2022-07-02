import 'package:flutter/material.dart';

/// Scaffold with a limited width, to prevent it growing too wide on widescreens.
class ConstrainedScaffold extends StatefulWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final double maxScaffoldWidth;

  const ConstrainedScaffold(
      {Key? key,
      required this.content,
      required this.title,
      this.actions,
      this.maxScaffoldWidth = 500})
      : super(key: key);

  @override
  State<ConstrainedScaffold> createState() => _ConstrainedScaffoldState();
}

class _ConstrainedScaffoldState extends State<ConstrainedScaffold> {
  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > widget.maxScaffoldWidth) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.maxScaffoldWidth),
                child: widget.content,
              );
            } else {
              return widget.content;
            }
          },
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: widget.actions,
      ),
      body: SafeArea(child: SingleChildScrollView(child: body)),
    );
  }
}

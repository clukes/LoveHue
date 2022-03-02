import 'package:flutter/material.dart';

class DefaultScaffold extends StatefulWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;

  const DefaultScaffold({Key? key, required this.content, required this.title, this.actions}) : super(key: key);

  @override
  State<DefaultScaffold> createState() => _DefaultScaffoldState();
}

class _DefaultScaffoldState extends State<DefaultScaffold> {
  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
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

import 'package:flutter/material.dart';

/// A [Dismissible] row that leaves the tree in the frame it is swiped away.
///
/// Its [onDismissed] starts an async delete, and the list keeps the row until the database
/// stream says it is gone. Any rebuild of the list in between (another provider it watches,
/// a background scan or nutrition fill) would rebuild the dismissed [Dismissible], which throws
/// "A dismissed Dismissible widget is still part of the tree".
class SwipeAway extends StatefulWidget {
  const SwipeAway({
    required Key key,
    required this.onDismissed,
    required this.child,
    this.direction = DismissDirection.endToStart,
    this.background,
  }) : super(key: key);

  final DismissDirectionCallback onDismissed;
  final DismissDirection direction;
  final Widget? background;
  final Widget child;

  @override
  State<SwipeAway> createState() => _SwipeAwayState();
}

class _SwipeAwayState extends State<SwipeAway> {
  bool _gone = false;

  @override
  Widget build(BuildContext context) {
    if (_gone) return const SizedBox.shrink();
    return Dismissible(
      key: widget.key!,
      direction: widget.direction,
      background: widget.background,
      onDismissed: (d) {
        setState(() => _gone = true);
        widget.onDismissed(d);
      },
      child: widget.child,
    );
  }
}

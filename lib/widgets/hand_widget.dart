import 'package:flutter/material.dart';

enum HandGesture { rock, paper, scissors }

class HandWidget extends StatelessWidget {
  final HandGesture? gesture;
  final double size;

  const HandWidget({
    super.key,
    this.gesture,
    this.size = 120,
  });

  String _getHandImagePath(HandGesture gesture) {
    switch (gesture) {
      case HandGesture.rock:
        return 'assets/hands/rock.png';
      case HandGesture.paper:
        return 'assets/hands/paper.png';
      case HandGesture.scissors:
        return 'assets/hands/scissors.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gesture == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            '❓',
            style: TextStyle(fontSize: size * 0.6),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        _getHandImagePath(gesture!),
        fit: BoxFit.contain,
        semanticLabel: gesture.toString(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class MarqueeOnOld extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final double height;

  const MarqueeOnOld({
    super.key,
    required this.text,
    this.textStyle,
    this.height = 20,
  });

  @override
  State<MarqueeOnOld> createState() => _MarqueeOnOldState();
}

class _MarqueeOnOldState extends State<MarqueeOnOld> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: LayoutBuilder(
        builder: (context, constraints){
          return SizedBox(
            height: widget.height,
            width: constraints.maxWidth,
            child: _isPressed ? Marquee(
              text: widget.text,
              style: widget.textStyle,
              scrollAxis: Axis.horizontal,
              blankSpace: 20.0,
              velocity: 30.0,
              pauseAfterRound: Duration(seconds: 1),
              startPadding: 10.0,
              accelerationDuration: Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ) : Text(
              widget.text,
              style: widget.textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ExpandedSection extends StatelessWidget {
  final Widget child;

  const ExpandedSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

class TontonText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow overflow;

  const TontonText(
    this.data, {
    super.key,
    this.style,
    this.align,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) => Text(
        data,
        maxLines: maxLines,
        textAlign: align,
        overflow: overflow,
        style: style ?? Theme.of(context).textTheme.bodyMedium,
      );
}

import 'package:flutter/material.dart';

extension FontWeightExtension on TextStyle {
  TextStyle bold(BuildContext context) => copyWith(
    fontWeight: FontWeight.bold,
    // color: Theme.of(context).colorScheme.surface,
  );
  TextStyle semibold(BuildContext context) => copyWith(
    fontWeight: FontWeight.w600,
    // color: Theme.of(context).colorScheme.surface,
  );
  TextStyle medium(BuildContext context) => copyWith(
    fontWeight: FontWeight.w500,
    // color: Theme.of(context).colorScheme.surface,
  );
  TextStyle light(BuildContext context) => copyWith(
    fontWeight: FontWeight.w300,
    // color: Theme.of(context).colorScheme.surface,
  );

  TextStyle mediumError(BuildContext context) =>
      copyWith(fontWeight: FontWeight.w500, color: Colors.red);
}

extension FontStylingContext on BuildContext {
  TextStyle get font =>
      Theme.of(this).textTheme.bodyMedium ?? const TextStyle();
}

// Usage:
// context.font.bold
// context.font.semibold
// context.font.medium
// context.font.light
// You can also chain: context.font.bold.copyWith(fontSize: 18)

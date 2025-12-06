import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import '../controllers/theme_controller.dart';

class ThemeChanger extends ConsumerWidget {
  final List<FlexScheme> schemes;
  final List<String> schemeNames;
  ThemeChanger({
    Key? key,
    this.schemes = FlexScheme.values,
    this.schemeNames = const [
      'Material',
      'Blue',
      'Indigo',
      'Hippie Blue',
      'Aqua Blue',
      'Brand Blue',
      'Deep Blue',
      'Ebony Clay',
      'Barossa',
      'Shark',
      'Big Stone',
      'Damask',
      'Bahama Blue',
      'Mallard Green',
      'Red',
      'Red Wine',
      'Purple Brown',
      'Mandy Red',
      'Espresso',
      'Outer Space',
      'Blue Whale',
      'San Juan Blue',
      'Rosewood',
      'Blumine Blue',
      'Verdun Green',
      'Dell Green',
      'Orange',
      'Gold',
      'Amber',
      'Vesuvius',
      'Deep Orange',
      'Pink',
      'Mauve',
      'Material Dark',
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    return themeAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (theme) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: theme.schemeIndex,
            icon: const Icon(Icons.arrow_drop_down),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            items: List.generate(schemes.length, (i) {
              final scheme = FlexScheme.values[i].colors(
                theme.themeMode == ThemeMode.dark
                    ? Brightness.dark
                    : Brightness.light,
              );

              return DropdownMenuItem<int>(
                value: i,
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    Text(
                      (schemeNames.length > i
                              ? schemeNames[i]
                              : schemes[i].name)
                          .capitalize,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
              );
            }),
            onChanged: (idx) {
              if (idx != null) controller.changeScheme(idx);
            },
            isDense: true,
          ),
        );
      },
    );
  }
}

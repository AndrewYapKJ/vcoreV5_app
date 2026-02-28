import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/controllers/theme_controller.dart';
import 'package:vcore_v5_app/services/localization_storage_service.dart';
import 'package:vcore_v5_app/themes/app_color_scheme.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final localizationStorage = LocalizationStorageService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: context.font
              .bold(context)
              .copyWith(fontSize: 20.sp, color: colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: themeAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text("Error loading theme")),
        data: (theme) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Mode Section
                _buildSectionTitle(context, 'appearance'.tr()),
                SizedBox(height: 12.h),
                _buildThemeModeCard(
                  context: context,
                  theme: theme,
                  controller: controller,
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 32.h),

                // Color Scheme Section
                _buildSectionTitle(context, 'color_scheme'.tr()),
                SizedBox(height: 12.h),
                _buildColorSchemeDropdown(
                  context: context,
                  theme: theme,
                  controller: controller,
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 32.h),

                // Language Section
                _buildSectionTitle(context, 'language'.tr()),
                SizedBox(height: 12.h),
                _buildLanguageDropdown(
                  context: context,
                  colorScheme: colorScheme,
                  localizationStorage: localizationStorage,
                ),
                SizedBox(height: 32.h),

                // Color Scheme Preview
                _buildSectionTitle(context, 'scheme_colors'.tr()),
                SizedBox(height: 12.h),
                _buildColorPreview(context, colorScheme, theme),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.font.semibold(context).copyWith(fontSize: 16.sp),
    );
  }

  Widget _buildThemeModeCard({
    required BuildContext context,
    required dynamic theme,
    required dynamic controller,
    required ColorScheme colorScheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              theme.themeMode == ThemeMode.light
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: colorScheme.secondary,
              size: 24.h,
            ),
            title: Text(
              'theme_mode'.tr(),
              style: context.font.medium(context).copyWith(fontSize: 14.sp),
            ),
            trailing: Text(
              theme.themeMode == ThemeMode.light ? 'light'.tr() : 'dark'.tr(),
              style: context.font
                  .regular(context)
                  .copyWith(
                    fontSize: 13.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ),
          Divider(height: 0, indent: 16.w, endIndent: 16.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    context: context,
                    label: 'light'.tr(),
                    isSelected: theme.themeMode == ThemeMode.light,
                    onTap: theme.themeMode != ThemeMode.light
                        ? () => controller.toggleThemeMode()
                        : null,
                    colorScheme: colorScheme,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildModeButton(
                    context: context,
                    label: 'dark'.tr(),
                    isSelected: theme.themeMode == ThemeMode.dark,
                    onTap: theme.themeMode != ThemeMode.dark
                        ? () => controller.toggleThemeMode()
                        : null,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: context.font
                .medium(context)
                .copyWith(
                  fontSize: 13.sp,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSchemeDropdown({
    required BuildContext context,
    required dynamic theme,
    required dynamic controller,
    required ColorScheme colorScheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: DropdownButton<int>(
          value: theme.schemeIndex,
          isExpanded: true,
          underline: SizedBox(),
          onChanged: (int? value) {
            if (value != null) {
              controller.changeScheme(value);
            }
          },
          items: List.generate(AppColorScheme.schemeCount, (i) {
            final scheme = AppColorScheme.getSchemeByIndex(i);
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final colors = isDarkMode ? scheme.dark : scheme.light;
            return DropdownMenuItem(
              value: i,
              child: Row(
                children: [
                  // Primary color square
                  Container(
                    width: 28.h,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Secondary color square
                  Container(
                    width: 28.h,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: colors.secondary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Scheme name
                  Text(
                    AppColorScheme.getSchemeNameByIndex(i),
                    style: context.font
                        .regular(context)
                        .copyWith(fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildColorPreview(
    BuildContext context,
    ColorScheme colorScheme,
    dynamic theme,
  ) {
    final scheme = AppColorScheme.getSchemeByIndex(theme.schemeIndex);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = isDarkMode ? scheme.dark : scheme.light;

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1,
      shrinkWrap: true,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.h,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildColorBox(label: 'Primary', color: colors.primary),
        _buildColorBox(label: 'Secondary', color: colors.secondary),
        _buildColorBox(label: 'Tertiary', color: colors.tertiary),
        _buildColorBox(label: 'Surface', color: colorScheme.surface),
        _buildColorBox(
          label: 'Error',
          color: colors.error ?? colorScheme.error,
        ),
        _buildColorBox(label: 'Outline', color: colorScheme.outline),
      ],
    );
  }

  Widget _buildColorBox({required String label, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50.h,
            height: 50.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required BuildContext context,
    required ColorScheme colorScheme,
    required LocalizationStorageService localizationStorage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: DropdownButton<String>(
          value: context.locale.languageCode,
          isExpanded: true,
          underline: SizedBox(),
          onChanged: (String? value) {
            if (value != null) {
              context.setLocale(Locale(value));
              localizationStorage.saveLocale(value);
            }
          },
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(
                'english'.tr(),
                style: context.font.regular(context).copyWith(fontSize: 14.sp),
              ),
            ),
            DropdownMenuItem(
              value: 'ms',
              child: Text(
                'malay'.tr(),
                style: context.font.regular(context).copyWith(fontSize: 14.sp),
              ),
            ),
            DropdownMenuItem(
              value: 'zh',
              child: Text(
                'chinese'.tr(),
                style: context.font.regular(context).copyWith(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

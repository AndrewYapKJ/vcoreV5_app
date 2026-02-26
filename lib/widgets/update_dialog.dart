import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialogs {
  /// Show force update dialog (redirects to store)
  static Future<void> showForceUpdateDialog(
    BuildContext context, {
    required String currentVersion,
    required String newVersion,
    required String storeUrl,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('update_available'.tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('update_required_message'.tr()),
                const SizedBox(height: 16),
                Text(
                  '${'current_version'.tr()}: $currentVersion',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${'new_version'.tr()}: $newVersion',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FilledButton(
                child: Text('update_now'.tr()),
                onPressed: () async {
                  final uri = Uri.parse(storeUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show Shorebird patch dialog
  static Future<bool> showPatchUpdateDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: Text('patch_available'.tr()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('patch_download_message'.tr()),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'patch_restart_instruction'.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('update_later'.tr()),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  FilledButton(
                    child: Text('update_now'.tr()),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
  }

  /// Show downloading patch progress dialog
  static void showDownloadingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('downloading_update'.tr()),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show patch download complete dialog with restart instructions
  static Future<void> showPatchCompleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text('update_downloaded'.tr()),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'patch_restart_required'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'restart_instructions'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. ${'close_app_instruction'.tr()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        '2. ${'reopen_app_instruction'.tr()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        '3. ${'update_active_instruction'.tr()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FilledButton(
                child: Text('got_it'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text('error'.tr()),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('ok'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

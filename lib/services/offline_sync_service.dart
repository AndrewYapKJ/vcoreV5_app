import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Model for storing offline API actions
class OfflineApiAction {
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  OfflineApiAction({
    required this.endpoint,
    required this.method,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'endpoint': endpoint,
    'method': method,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };

  factory OfflineApiAction.fromJson(Map<String, dynamic> json) =>
      OfflineApiAction(
        endpoint: json['endpoint'],
        method: json['method'],
        payload: Map<String, dynamic>.from(json['payload']),
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// Service to store and sync offline API actions
class OfflineSyncService {
  static const String _offlineActionsKey = 'offline_api_actions';
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  Future<void> addAction(OfflineApiAction action) async {
    final prefs = await SharedPreferences.getInstance();
    final actions = await getActions();
    actions.add(action);
    final encoded = jsonEncode(actions.map((a) => a.toJson()).toList());
    await prefs.setString(_offlineActionsKey, encoded);
    debugPrint('Offline action added: ${action.endpoint}');
  }

  Future<List<OfflineApiAction>> getActions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_offlineActionsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => OfflineApiAction.fromJson(e)).toList();
  }

  Future<void> clearActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineActionsKey);
  }

  /// Call this when online to sync all actions
  Future<void> syncActions(
    Future<bool> Function(OfflineApiAction) sendAction,
  ) async {
    final actions = await getActions();
    for (final action in actions) {
      final success = await sendAction(action);
      if (success) {
        debugPrint('Synced action: ${action.endpoint}');
      } else {
        debugPrint('Failed to sync action: ${action.endpoint}');
        // Optionally break or retry later
      }
    }
    await clearActions();
  }
}

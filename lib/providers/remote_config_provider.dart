import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcore_v5_app/services/remote_config_service.dart';

/// Provider for RemoteConfigService singleton
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

/// Provider to fetch data from remote config
final remoteConfigValueProvider = FutureProvider.family<dynamic, String>((
  ref,
  key,
) async {
  final service = ref.watch(remoteConfigServiceProvider);
  // This is a simple example - you can enhance this to return different types
  return service.getString(key);
});

// /// Provider to check which remote config provider is active
// final remoteConfigProviderProvider = Provider<String>((ref) {
//   final service = ref.watch(remoteConfigServiceProvider);
//   return service.activeProvider.toString();
// });

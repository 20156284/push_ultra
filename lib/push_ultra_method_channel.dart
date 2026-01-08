import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'push_ultra_platform_interface.dart';

/// An implementation of [PushUltraPlatform] that uses method channels.
class MethodChannelPushUltra extends PushUltraPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('push_ultra');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

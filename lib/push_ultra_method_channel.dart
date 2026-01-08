import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'push_ultra_platform_interface.dart';

/// An implementation of [PushUltraPlatform] that uses method channels.
class MethodChannelPushUltra extends PushUltraPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('push_ultra');
  
  Function(Map<String, dynamic>)? _notificationHandler;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> setupAppleApns() async {
    final result = await methodChannel.invokeMethod<bool>('setupAppleApns');
    return result ?? false;
  }

  @override
  Future<Map<String, dynamic>> getRemoteNotificationDeviceToken() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getRemoteNotificationDeviceToken');
    return (result ?? {}) as Map<String, dynamic>;
  }

  @override
  void setNotificationHandler(Function(Map<String, dynamic>) handler) {
    _notificationHandler = handler;
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onReceiveNotification') {
      final data = call.arguments as Map<Object?, Object?>;
      final notificationData = Map<String, dynamic>.from(data as Map);
      _notificationHandler?.call(notificationData);
    }
  }
}

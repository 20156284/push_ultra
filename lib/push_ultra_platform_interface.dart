import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'push_ultra_method_channel.dart';

abstract class PushUltraPlatform extends PlatformInterface {
  /// Constructs a PushUltraPlatform.
  PushUltraPlatform() : super(token: _token);

  static final Object _token = Object();

  static PushUltraPlatform _instance = MethodChannelPushUltra();

  /// The default instance of [PushUltraPlatform] to use.
  ///
  /// Defaults to [MethodChannelPushUltra].
  static PushUltraPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PushUltraPlatform] when
  /// they register themselves.
  static set instance(PushUltraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// 设置 Apple APNS
  Future<bool> setupAppleApns() {
    throw UnimplementedError('setupAppleApns() has not been implemented.');
  }

  /// 获取远程推送设备 Token
  Future<Map<String, dynamic>> getRemoteNotificationDeviceToken() {
    throw UnimplementedError('getRemoteNotificationDeviceToken() has not been implemented.');
  }

  /// 设置推送通知回调
  void setNotificationHandler(Function(Map<String, dynamic>) handler) {
    throw UnimplementedError('setNotificationHandler() has not been implemented.');
  }
}

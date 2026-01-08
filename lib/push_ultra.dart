
import 'push_ultra_platform_interface.dart';

class PushUltra {
  Future<String?> getPlatformVersion() {
    return PushUltraPlatform.instance.getPlatformVersion();
  }

  /// 设置 Apple APNS
  Future<bool> setupAppleApns() {
    return PushUltraPlatform.instance.setupAppleApns();
  }

  /// 获取远程推送设备 Token
  Future<Map<String, dynamic>> getRemoteNotificationDeviceToken() {
    return PushUltraPlatform.instance.getRemoteNotificationDeviceToken();
  }

  /// 设置推送通知回调
  /// [handler] 接收推送通知的回调函数，参数格式：{"payload": {...}, "notificationType": "foreground"|"background"|"tap"}
  void setNotificationHandler(Function(Map<String, dynamic>) handler) {
    PushUltraPlatform.instance.setNotificationHandler(handler);
  }
}


import 'push_ultra_platform_interface.dart';

class PushUltra {
  Future<String?> getPlatformVersion() {
    return PushUltraPlatform.instance.getPlatformVersion();
  }
}

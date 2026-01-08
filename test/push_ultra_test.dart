import 'package:flutter_test/flutter_test.dart';
import 'package:push_ultra/push_ultra.dart';
import 'package:push_ultra/push_ultra_platform_interface.dart';
import 'package:push_ultra/push_ultra_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPushUltraPlatform
    with MockPlatformInterfaceMixin
    implements PushUltraPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PushUltraPlatform initialPlatform = PushUltraPlatform.instance;

  test('$MethodChannelPushUltra is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPushUltra>());
  });

  test('getPlatformVersion', () async {
    PushUltra pushUltraPlugin = PushUltra();
    MockPushUltraPlatform fakePlatform = MockPushUltraPlatform();
    PushUltraPlatform.instance = fakePlatform;

    expect(await pushUltraPlugin.getPlatformVersion(), '42');
  });
}

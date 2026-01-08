#include "include/push_ultra/push_ultra_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "push_ultra_plugin.h"

void PushUltraPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  push_ultra::PushUltraPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

import Flutter
import UIKit
import UserNotifications

public class PushUltraPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    
    private var methodChannel: FlutterMethodChannel?
    private var tokenValue: String = ""
    private var isProd: Bool = false
    
    /// Flutter 未 ready 时缓存推送
    private var pendingNotifications: [[AnyHashable: Any]] = []
    
    /// 单例实例，用于 AppDelegate 访问
    public static var shared: PushUltraPlugin?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "push_ultra", binaryMessenger: registrar.messenger())
        let instance = PushUltraPlugin()
        instance.methodChannel = channel
        shared = instance
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // 设置推送代理
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = instance
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            
        case "setupAppleApns":
            setUpAPNS { [weak self] in
                self?.flushPending()
                result(true)
            }
            
        case "getRemoteNotificationDeviceToken":
            result([
                "token": tokenValue,
                "isProd": isProd
            ])
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - APNS 设置
    
    private func setUpAPNS(completion: @escaping () -> Void) {
        guard #available(iOS 10.0, *) else {
            completion()
            return
        }
        
        let center = UNUserNotificationCenter.current()
        
        // 确保 delegate 被设置
        if center.delegate !== self {
            center.delegate = self
        }
        
        // 请求推送权限
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        
        center.requestAuthorization(options: options) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                // 权限请求完成后，立即调用 completion
                completion()
            }
        }
    }
    
    // MARK: - 设备 Token 处理（供 AppDelegate 调用）
    
    public static func didRegisterForRemoteNotifications(deviceToken: Data) {
        shared?.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }
    
    public static func didFailToRegisterForRemoteNotifications(error: Error) {
        shared?.didFailToRegisterForRemoteNotifications(error: error)
    }
    
    public static func handleLaunchNotification(userInfo: [AnyHashable: Any]) {
        shared?.handleLaunchNotification(userInfo: userInfo)
    }
    
    private func didRegisterForRemoteNotifications(deviceToken: Data) {
        let hex = deviceToken.map { String(format: "%02x", $0) }.joined()
        tokenValue = hex
        
        let isSandbox = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        isProd = !isSandbox
    }
    
    private func didFailToRegisterForRemoteNotifications(error: Error) {
        // Token 获取失败
    }
    
    // MARK: - 推送代理方法
    
    /// 前台收到通知时触发（不是点击，只是收到通知）
    @available(iOS 10.0, *)
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        
        // 前台收到通知：标记为 foreground
        cacheOrSendToFlutter(userInfo, notificationType: "foreground")
        
        // 让系统在前台也显示 声音、badge
        if #available(iOS 14.0, *) {
            completionHandler([.list, .sound, .badge])
        } else {
            completionHandler([.sound, .badge])
        }
    }
    
    /// 用户点击通知（后台、前台或已杀死状态都会触发）
    @available(iOS 10.0, *)
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // 判断应用状态：后台点击通知
        let appState = UIApplication.shared.applicationState
        let notificationType = (appState == .background) ? "background" : "tap"
        
        // 用户点击通知，发送给 Flutter 处理跳转
        cacheOrSendToFlutter(userInfo, notificationType: notificationType)
        
        // 通知系统处理完成
        completionHandler()
    }
    
    // MARK: - 推送消息处理
    
    /// 处理冷启动时被通知点开
    private func handleLaunchNotification(userInfo: [AnyHashable: Any]) {
        var cachedInfo: [AnyHashable: Any] = userInfo
        cachedInfo["_notificationType"] = "tap"
        pendingNotifications.append(cachedInfo)
    }
    
    /// 缓存或发送通知给 Flutter
    private func cacheOrSendToFlutter(_ userInfo: [AnyHashable: Any], notificationType: String) {
        guard let channel = methodChannel else {
            // Flutter 未就绪，缓存推送
            var cachedInfo: [AnyHashable: Any] = userInfo
            cachedInfo["_notificationType"] = notificationType
            pendingNotifications.append(cachedInfo)
            return
        }
        
        // 构造 Flutter 期望的数据格式
        let args: [String: Any] = [
            "payload": userInfo,
            "notificationType": notificationType
        ]
        
        channel.invokeMethod("onReceiveNotification", arguments: args)
    }
    
    /// 把启动时或 Flutter 未 ready 时缓存的推送一次性发给 Flutter
    private func flushPending() {
        guard let channel = methodChannel, !pendingNotifications.isEmpty else {
            return
        }
        
        for cachedInfo in pendingNotifications {
            // 提取通知类型（默认为 tap）
            let notificationType = cachedInfo["_notificationType"] as? String ?? "tap"
            
            // 移除临时添加的类型字段，恢复原始 userInfo
            var userInfo = cachedInfo
            userInfo.removeValue(forKey: "_notificationType")
            
            // 构造 Flutter 期望的数据格式
            let args: [String: Any] = [
                "payload": userInfo,
                "notificationType": notificationType
            ]
            
            channel.invokeMethod("onReceiveNotification", arguments: args)
        }
        
        pendingNotifications.removeAll()
    }
}

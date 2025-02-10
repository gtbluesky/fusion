# Fusion
[![pub package](https://img.shields.io/pub/v/fusion.svg)](https://pub.dev/packages/fusion)

| **OS**        | Android    | iOS   | HarmonyOS |
|---------------|------------|-------|-----------|
| **SDK**   | 5.0(21)+   | 11.0+ | 5.0(13)+  |

## 简介

Fusion 是新一代的混合栈管理框架，用于 Flutter 与 Native 页面统一管理，并支持页面通信、页面生命周期监听等功能。Fusion 即 `融合`，我们的设计初衷就是帮助开发者在使用 Flutter 与 Native 进行混合开发时尽量感受不到两者的隔阂，提升开发体验。

从 4.0 开始，Fusion 已完成纯鸿蒙平台（HarmonyOS Next/OpenHarmony，以下简称 HarmonyOS）的适配，开发者可以在Android、iOS、HarmonyOS上得到完全一致的体验。（HarmonyOS 的 Flutter SDK 可以在[这里](https://gitee.com/openharmony-sig/flutter_flutter)获取）

Fusion 采用引擎复用方案，在 Flutter 与 Native 页面多次跳转情况下，APP 始终仅有一份 FlutterEngine 实例，因此拥有更好的性能和更低的内存占用。

Fusion 也是目前仅有的支持混合开发时应用在后台被系统回收后，所有Flutter页面均可正常恢复的混合栈框架。

## 开始使用

### 0、准备

在开始前需要按照 [Flutter 官方文档](https://docs.flutter.dev/development/add-to-app)，将 Flutter Module 项目接入到 Android、iOS、HarmonyOS 工程中。

### 1、初始化

Flutter 侧

使用 FusionApp 替换之前使用的 App Widget，并传入所需路由表，默认路由表和自定义路由表可单独设置也可同时设置。

```dart
void main() {
  runApp(FusionApp(
    // 默认路由表
    routeMap: routeMap,
    // 自定义路由表
    customRouteMap: customRouteMap,
  ));
}

// 默认路由表，使用默认的 PageRoute
// 使用统一的路由动画
final Map<String, FusionPageFactory> routeMap = {
  '/test': (arguments) => TestPage(arguments: arguments),
  kUnknownRoute: (arguments) => UnknownPage(arguments: arguments),
};

// 自定义路由表，可自定义 PageRoute
// 比如：某些页面需要特定的路由动画则可使用该路由表
final Map<String, FusionPageCustomFactory> customRouteMap = {
  '/mine': (settings) => PageRouteBuilder(
      opaque: false,
      settings: settings,
      pageBuilder: (_, __, ___) => MinePage(
          arguments: settings.arguments as Map<String, dynamic>?)),
};
```
P.S: `kUnknownRoute`表示未定义路由

注意：如果项目使用了 `flutter_screenutil`，需要在 runApp 前调用 `Fusion.instance.install()`，没有使用 `flutter_screenutil`则无须该步骤。

```dart
void main() {
  Fusion.instance.install();
  runApp(FusionApp(
    // 默认路由表
    routeMap: routeMap,
    // 自定义路由表
    customRouteMap: customRouteMap,
  ));
}
```



Android 侧

在 Application 中进行初始化，并实现 FusionRouteDelegate 接口

```kotlin
class MyApplication : Application(), FusionRouteDelegate {

    override fun onCreate() {
        super.onCreate()
        Fusion.install(this, this)
    }

    override fun pushNativeRoute(name: String?, arguments: Map<String, Any>?) {
        // 根据路由 name 跳转对应 Native 页面
    }

    override fun pushFlutterRoute(name: String?, arguments: Map<String, Any>?) {
        // 根据路由 name 跳转对应 Flutter 页面
        // 可在 arguments 中存放参数判断是否需要打开透明页面
    }
}
```

iOS 侧

在 AppDelegate 中进行初始化，并实现 FusionRouteDelegate 代理

```swift
@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate, FusionRouteDelegate {
    
    func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      ...
      Fusion.instance.install(self)
      ...
    return true
  }
    
    func pushNativeRoute(name: String?, arguments: Dictionary<String, Any>?) {
        // 根据路由 name 跳转对应 Native 页面
    }
    
    func pushFlutterRoute(name: String?, arguments: Dictionary<String, Any>?) {
        // 根据路由 name 跳转对应 Flutter 页面
        // 可在 arguments 中存放参数判断是否需要打开透明页面
        // 可在 arguments 中存放参数判断是 push 还是 present
    }
}
```
HarmonyOS 侧

在 UIAbility 中进行初始化，并实现 FusionRouteDelegate 代理
```typescript
export default class EntryAbility extends UIAbility implements FusionRouteDelegate {
  private static TAG = 'EntryAbility'
  private mainWindow: window.Window | null = null
  private windowStage: window.WindowStage | null = null

  override async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    await Fusion.instance.install(this.context, this)
    GeneratedPluginRegistrant.registerWith(Fusion.instance.defaultEngine!)
  }

  override onWindowStageCreate(windowStage: window.WindowStage): void {
    this.windowStage = windowStage
    this.mainWindow = windowStage.getMainWindowSync()
    windowStage.loadContent('pages/IndexPage')
  }

  pushNativeRoute(name: string, args: Map<string, Object> | null): void {
    // 根据路由 name 跳转对应 Native 页面
  }

  pushFlutterRoute(name: string, args: Map<string, Object> | null): void {
    // 根据路由 name 跳转对应 Flutter 页面
    // 可在 arguments 中存放参数判断是否需要打开透明页面
  }
}
```
### 2、Flutter 容器

#### 普通页面模式

Android 侧

通过 `FusionActivity`（或其子类） 创建 Flutter 容器，启动容器时需要使用 Fusion 提供的 `buildFusionIntent` 方法，其中参数 `transparent` 需设为 false。其 xml 配置参考如下（如果使用 `FusionActivity` 则不用配置）：

```xml
        <activity
            android:name=".CustomFusionActivity"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:exported="false"
            android:hardwareAccelerated="true"
            android:launchMode="standard"
            android:theme="@style/FusionNormalTheme"
            android:windowSoftInputMode="adjustResize" />
```


iOS 侧

通过 `FusionViewController` （或其子类）创建 Flutter 容器，`push` 和 `present` 均支持。FusionViewController 默认隐藏了 UINavigationController。

在 iOS 中需要处理原生右滑退出手势和 Flutter 手势冲突的问题，解决方法也很简单：只需在自定义的 Flutter 容器中实现 `FusionPopGestureHandler` 并在对应方法中启用或者关闭原生手势即可，这样可以实现如果当前 Flutter 容器存在多个 Flutter 页面时，右滑手势是退出 Flutter 页面，而当 Flutter 页面只有一个时则右滑退出 Flutter 容器。

```swift
    // 启用原生手势
    func enablePopGesture() {
        // 以下代码仅做演示，不可直接照搬，需根据APP实际情况自行实现
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    // 关闭原生手势
    func disablePopGesture() {
        // 以下代码仅做演示，不可直接照搬，需根据APP实际情况自行实现
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
```

HarmonyOS 侧

通过 `FusionEntry`（或其子类） 创建 Flutter 容器，启动容器时需要使用 Fusion 提供的 `buildFusionParams` 方法，也可直接使用 `FusionPage`。默认全屏模式。
```typescript
    const params = buildFusionParams(name, args, false, backgroundColor)
    Fusion.instance.navPathStack?.pushPathByName('CustomFusionPage', params)
```

#### 透明页面模式

Android 侧

使用方式与普通页面模式相似，只是`buildFusionIntent` 方法的参数 `transparent `需设为 true，其 xml 配置参考如下：

```xml
        <activity
            android:name=".TransparentFusionActivity"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:exported="false"
            android:hardwareAccelerated="true"
            android:launchMode="standard"
            android:theme="@style/FusionTransparentTheme"
            android:windowSoftInputMode="adjustResize" />
```

iOS 侧

使用方式与普通页面模式相似：

```swift
let fusionVc = CustomViewController(routeName: name, routeArguments: arguments, transparent: true)
navController?.present(fusionVc, animated: false)
```

HarmonyOS 侧

使用方式与普通页面模式相似：
```typescript
    const params = buildFusionParams(name, args, true, backgroundColor)
    Fusion.instance.navPathStack?.disableAnimation(true)
    Fusion.instance.navPathStack?.pushPathByName('CustomFusionPage', params)
```

Flutter 侧

同时Flutter页面背景也需要设置为透明


#### 子页面模式

子页面模式是指一个或多个 Flutter 页面同时嵌入到 Native 容器中的场景，如：使用Tab切换Flutter和原生页面，Fusion 支持多个 Flutter 页面嵌入同一个 Native 容器中

Android 侧

使用 FusionFragment 以支持子页面模式，创建 FusionFragment 对象需要使用 `buildFusionFragment` 方法

iOS 侧

与页面模式一样使用 FusionViewController 

HarmonyOS 侧

与页面模式一样使用 FusionEntry，配合 `buildFusionParams`方法配置参数，通过 `FusionComponent` 传入 `childMode: true`

#### 自定义容器背景色

默认情况下容器的背景为白色，这是因为考虑到绝大多数的页面都是使用白色背景，但如果打开的首个Flutter页面的背景是其他颜色，比如夜间模式下页面为深灰色，此时是为了更好的视觉效果，可以自定义容器的背景色与首个Flutter页面的背景色一致。

Android 侧

在 `buildFusionIntent` 和 `buildFusionFragment`方法中参数 `backgroundColor` 设为所需背景色

iOS 侧

在创建 FusionViewController （或其子类）对象时，参数 `backgroundColor` 设为所需背景色

HarmonyOS 侧

在 `buildFusionParams`方法中参数 `backgroundColor` 设为所需背景色

### 3、路由API（FusionNavigator）

- push: 将对应路由入栈，使用 Navigator.pushNamed 与之等同，根据FusionRouteType分为以下几种方式：
  - flutter模式: 在当前Flutter容器中将指定路由对应的Flutter页面入栈，如果没有则跳转kUnknownRoute对应Flutter页面
  - flutterWithContainer模式: 创建一个新的Flutter容器，并将指定路由对应的Flutter页面入栈，如果没有则跳转kUnknownRoute对应Flutter页面。即执行FusionRouteDelegate的pushFlutterRoute
  - native模式: 将指定路由对应的Native页面入栈，即执行FusionRouteDelegate的pushNativeRoute
  - adaption模式: 自适应模式，默认类型。首先判断该路由是否是Flutter路由，如果不是则进入native模式，如果是再判断当前是否是页面是否是Flutter容器，如果是则进入flutter模式，如果不是则进入flutterWithContainer模式
- pushAndClear: 将指定路由入栈，并清空栈中其他路由
- pop: 将栈顶路由出栈，使用 Navigator.pop 与之等同
- popUntil: 将栈顶路由出栈，直到指定路由（只能在栈顶路由与目标路由之间不存在原生容器的场景下使用）
- maybePop: 将栈顶路由出栈，可被WillPopScope拦截
- replace: 将栈顶路由替换为对应路由
- remove: 移除对应路由
- hasRouteByName：路由栈中是否存在该路由名对应的路由

### 4、Flutter Plugin 注册

在 Android 和 iOS 平台上框架内部会自动注册插件，无须手动调用 `GeneratedPluginRegistrant.registerWith` 进行注册，但 HarmonyOS 必须手动调用该方法。

### 5、自定义 Channel

如果需要 Native 与 Flutter 进行通信，则需要自行创建 Channel，创建 Channel 方式如下（以 MethodChannel 为例）：

Android 侧

①、与容器无关的方法

在 Application 中进行注册

```kotlin
val channel = Fusion.defaultEngine?.dartExecutor?.binaryMessenger?.let {
    MethodChannel(
        it,
        "custom_channel"
    )
}
channel?.setMethodCallHandler { call, result -> 
}
```

②、与容器相关的方法

在自实现的 FusionActivity、FusionFragmentActivity、FusionFragment 上实现 FusionMessengerHandler 接口，在 configureFlutterChannel 中创建 Channel，在 releaseFlutterChannel 释放 Channel

```kotlin
class CustomActivity : FusionActivity(), FusionMessengerHandler {
  
    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        val channel = MethodChannel(binaryMessenger, "custom_channel")
        channel.setMethodCallHandler { call, result -> 
            
        }
    }
  
    override fun releaseFlutterChannel() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
```



iOS 侧

①、与容器无关的方法

在 AppDelegate 中进行注册

```swift
var channel: FlutterMethodChannel? = nil
if let binaryMessenger = Fusion.instance.defaultEngine?.binaryMessenger {
    channel = FlutterMethodChannel(name: "custom_channel", binaryMessenger: binaryMessenger)
}
channel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
}
```

②、与容器相关的方法

在自实现的 FusionViewController 上实现 FusionMessengerHandler 协议，在协议方法中创建 Channel

```swift
class CustomViewController : FusionViewController, FusionMessengerHandler {
    func configureFlutterChannel(binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "custom_channel", binaryMessenger: binaryMessenger)
        channel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            
        }
    }
    
    func releaseFlutterChannel() {
        channel?.setMethodCallHandler(nil)
        channel = nil
    }
}
```

HarmonyOS 侧

①、与容器无关的方法

在 UIAbility 中进行注册

```typescript
const binaryMessenger = Fusion.instance.defaultEngine?.dartExecutor.getBinaryMessenger()
const channel = new MethodChannel(binaryMessenger!, 'custom_channel')
channel.setMethodCallHandler({
  onMethodCall(call: MethodCall, result: MethodResult): void {
    
  }
})
```

②、与容器相关的方法

在自实现的 FusionEntry 上实现 FusionMessengerHandler 接口，在 configureFlutterChannel 中创建 Channel，在 releaseFlutterChannel 释放 Channel

```typescript
export default class CustomFusionEntry extends FusionEntry implements FusionMessengerHandler, MethodCallHandler {
  private channel: MethodChannel | null = null

  configureFlutterChannel(binaryMessenger: BinaryMessenger): void {
    this.channel = new MethodChannel(binaryMessenger, 'custom_channel')
    this.channel.setMethodCallHandler(this)
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    result.success(`Custom Channel：${this}_${call.method}`)
  }

  releaseFlutterChannel(): void {
    this.channel?.setMethodCallHandler(null)
    this.channel = null
  }
}
```

> BasicMessageChannel 和 EventChannel 使用也是类似

P.S.: 与容器相关的方法是与容器生命周期绑定的，如果容器不可见或者销毁了则无法收到Channel消息。

### 6、生命周期
应用生命周期监听：
- ①、在 Flutter 侧任意处注册监听皆可，并`implements` FusionAppLifecycleListener
- ②、根据实际情况决定是否需要注销监听
```dart
void main() {
  ...
  FusionAppLifecycleManager.instance.register(MyAppLifecycleListener());
  runApp(const MyApp());
}

class MyAppLifecycleListener implements FusionAppLifecycleListener {
  @override
  void onBackground() {
    print('onBackground');
  }

  @override
  void onForeground() {
    print('onForeground');
  }
}
```
FusionAppLifecycleListener 生命周期回调函数：
- onForeground: 应用进入前台会被调用（首次启动不会被调用，Android 与 iOS 保持一致）
- onBackground: 应用退到后台会被调用

页面生命周期监听：
- ①、在需要监听生命周期页面的 State 中 `with` FusionPageLifecycleMixin
```dart
class LifecyclePage extends StatefulWidget {
  const LifecyclePage({Key? key}) : super(key: key);

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage>
    with FusionPageLifecycleMixin {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void onPageVisible() {}

  @override
  void onPageInvisible() {}

  @override
  void onForeground() {}

  @override
  void onBackground() {}
}
```
生命周期回调函数：
- onForeground: 应用进入前台会被调用，所有注册了生命周期监听的页面都会收到
- onBackground: 应用退到后台会被调用，所有注册了生命周期监听的页面都会收到
- onPageVisible: 该 Flutter 页面可见时被调用，如：从 Native 页面或其他 Flutter 页面 `push` 到该 Flutter 页面时；从 Native 页面或其他 Flutter 页面 `pop` 到该 Flutter 页面时；应用进入前台时也会被调用。
- onPageInvisible: 该 Flutter 页面不可见时被调用，如：从该 Flutter 页面 `push` 到 Native 页面或其他 Flutter 页面时；如从该 Flutter 页面 `pop` 到 Native 页面或其他 Flutter 页面时；应用退到后台时也会被调用。

### 7、全局事件
#### 注册事件回调
Flutter侧
- ①、在合适时机通过`register`注册事件回调
- ②、在合适时机通过`unregister`注销事件回调，如果传入callback则只注销该callback，如果不传callback则该event对应的所有callback均被注销
```dart
class TestPage extends StatefulWidget {

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  void onReceive(Map<String, dynamic>? args) {
    
  }

  @override
  void initState() {
    super.initState();
    FusionEventManager.instance.register('custom_event', onReceive);
  }

  @override
  void dispose() {
    super.dispose();
    FusionEventManager.instance.unregister('custom_event');
  }
}
```

Native侧
- ①、在合适时机通过`register`注册事件回调
- ②、在合适时机通过`unregister`注销事件回调，如果传入callback则只注销该callback，如果不传callback则该event对应的所有callback均被注销

* 注意：在iOS上，由于closure的相等性检测机制问题，如果需要注销指定callback，则不能直接传入Swift函数引用，需按以下方式定义，如果不需要注销指定callback，则可以使用平台支持的任意closure定义方式：

```swift
    // 事件回调定义1
    let onReceive: FusionEventCallback = { args in
        NSLog("onReceive: args=\(String(describing: args))")
    }
    // 事件回调定义2
    lazy var onReceive: FusionEventCallback = onReceiveFunc
   
    public func onReceiveFunc(args: Dictionary<String, Any>?) {
        NSLog("onReceive: args=\(String(describing: args))")
    }
    // 注册
    FusionEventManager.instance.register("custom_event", callback: onReceive)
```

#### 发送时间
三端均可使用`FusionEventManager` 的 `send` 方法来发送事件，根据使用FusionEventType 不同类型有不同效果：
- flutter: 仅 Flutter 可以收到
- native: 仅 Native 可以收到
- global: Flutter 和 Native 都可以收到

### 8、返回拦截

在纯 Flutter 开发中可以使用`WillPopScope`组件拦截返回操作，Fusion 也完整支持该功能，使用方式与在纯 Flutter 开发完全一致，此外使用`FusionNavigator.maybePop`的操作也可被`WillPopScope`组件拦截。

### 9、状态恢复

Fusion 支持 Android 和 iOS 平台 APP 被回收后 Flutter 路由的恢复。

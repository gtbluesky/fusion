# Fusion
[![pub package](https://img.shields.io/pub/v/fusion.svg)](https://pub.dev/packages/fusion)

## 简介

Fusion 是新一代的混合管理框架，用于 Flutter 与 Native 页面统一管理，并支持页面通信、页面生命周期监听等功能。Fusion 即 `融合`，我们的设计初衷就是帮助开发者在使用 Flutter 与 Native 进行混合开发时尽量感受不到两者的隔阂，提升开发体验。

Fusion 采用引擎复用方案，在 Flutter 与 Native 页面多次跳转情况下，APP 始终仅有一份 FlutterEngine 实例，因此拥有更好的性能和更低的内存占用，即使在 debug 模式下打开 Flutter 容器也拥有媲美原生页面的打开速度。此外，Fusion 也支持基于 EngineGroup 的多 Engine 模式，以支持 Flutter 页面嵌套在 Native 页面中的场景。

不像其他类似框架，随着 Flutter 版本的更新往往需要对框架本身进行版本适配工作，如果开发者维护不及时就会导致整个项目都无法使用新版 Flutter，而 Fusion 优秀的兼容性使得使用者可以更加从容地升级 Flutter 版本，目前支持 Flutter SDK 从 2.0 到 3.x 的全部版本。

## 开始使用

### 0、准备

在开始前需要按照 [Flutter 官方文档](https://docs.flutter.dev/development/add-to-app)，将 Flutter Module 项目接入到 Android 和 iOS 工程中。

### 1、初始化

Flutter 侧

使用 FusionApp 替换之前使用的 App Widget，并传入自定义的路由表

```dart
void main() {
  runApp(FusionApp(
    routeMap,
  ));
}

// 路由表
final Map<String, FusionPageFactory> routeMap = {
  '/test': (arguments) => TestPage(arguments: arguments),
  unknownRoute: (arguments) => UnknownPage(arguments: arguments),
};
```
P.S: 请勿使用`/`路由，`unknownRoute`表示未定义路由

Android 侧

在 Application 中进行初始化，并实现 FusionRouteDelegate 接口

```kotlin
class MyApplication : Application(), FusionRouteDelegate {

    override fun onCreate() {
        super.onCreate()
        Fusion.install(this, this)
    }

    override fun pushNativeRoute(name: String?, arguments: Map<String, Any>?) {
        // Flutter 跳转 Native 页面时被调用
      	// 根据路由 name 跳转对应原生 Activity
    }

    override fun pushFlutterRoute(name: String?, arguments: Map<String, Any>?) {
        // Native 跳转 Flutter 页面时被调用
      	// 根据路由 name 跳转对应 FusionActivity 或其子类
      	context?.let {
        	it.startActivity(buildFusionIntent(it, CustomFusionActivity::class.java, name, arguments))
        }
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
      Fusion.instance.install(delegate: self)
      ...
    return true
  }
    
    func pushNativeRoute(name: String?, arguments: Dictionary<String, Any>?) {
        // Flutter 跳转 Native 页面时被调用
      	// 根据路由 name 跳转对应原生 VC
    }
    
    func pushFlutterRoute(name: String?, arguments: Dictionary<String, Any>?) {
        // Native 跳转 Flutter 页面时被调用
      	// 根据路由 name 跳转对应 FusionViewController 或其子类
        guard let name = name else {
            return
        }
        let nc = self.window?.rootViewController as? UINavigationController
        let fusionVc = CustomViewController(routeName: name, routeArguments: arguments)
        nc?.pushViewController(fusionVc, animated: true)
    }
}
```

### 2、Flutter 容器

#### 页面模式

Android 使用 FusionActivty，启动 FusionActivty（或其子类）时需要使用 Fusion 提供的 `buildFusionIntent` 方法。

iOS 使用 FusionViewController，可以直接使用，也可通过继承其创建新的 ViewController。FusionViewController 默认隐藏了 UINavigationController，并且将 iOS 和 Flutter 右滑手势返回兼容，使得 iOS 原生页面和 Flutter 页面都可通过手势返回。

P.S: 如果存在手势冲突，可以关闭手势自适应模式
```swift
Fusion.instance.adaptiveGesture = false
```

#### 嵌套模式
嵌套模式是指一个或多个 Flutter 页面以子页面形式嵌入到 Native 容器中的场景，Fusion 支持多个 Flutter 页面嵌入同一个 Native 容器中。

Android 使用 FusionFragment 以支持嵌套模式，创建 FusionFragment 对象需要使用 `buildFusionFragment` 方法。

iOS 使用 FusionViewController 并传入 `isReused: false` 以支持嵌套模式。

### 3、路由API（FusionNavigator）

open（New）：打开新Flutter容器并将对应路由入栈，Native页面跳转Flutter页面使用该API

push：在当前Flutter容器中将对应路由入栈

pop：在当前Flutter容器中将栈顶路由出栈

maybePop（New）：在当前Flutter容器中将栈顶路由出栈，可被WillPopScope拦截

replace：在当前Flutter容器中将栈顶路由替换为对应路由。目前其他框架均不支持该方法。

remove：在当前Flutter容器中移除对应路由

P.S. 除页面外其他类型如 Dialog 等请使用 Navigator 的 push 和 pop.

### 4、Flutter Plugin 注册

框架内部会自动注册插件，无须手动调用 `GeneratedPluginRegistrant.registerWith`

### 5、自定义 Channel

如果需要 Native 与 Flutter 进行通信，则需要自行创建 Channel，创建 Channel 方式如下（以 MethodChannel 为例）：

Android 侧

①、如果使用的是 FusionFragment 容器，则需在对应的 Activity 类上实现 FusionMessengerProvider 接口，在接口方法中创建 Channel

```kotlin
class MyActivity : FragmentActivity(), FusionMessengerProvider {
  
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //...
        //加载 FusionFragment
    }
  
    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        val channel = MethodChannel(binaryMessenger, "自定义的channel名")
        channel.setMethodCallHandler { call, result -> 
            
        }
    }
  
    override fun releaseFlutterChannel() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
```



②、如果使用的是 FusionActivity 容器，则需要创建一个新的 Activity 并继承 FusionActivity 并实现 FusionMessengerProvider 接口，在 configureFlutterChannel 中创建 Channel，在 releaseFlutterChannel 释放 Channel

```kotlin
class CustomActivity : FusionActivity(), FusionMessengerProvider {
  
    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        val channel = MethodChannel(binaryMessenger, "自定义的channel名")
        channel.setMethodCallHandler { call, result -> 
            
        }
    }
  
    override fun releaseFlutterChannel() {
        channel?.setMethodCallHandler(null)
        channle = null
    }
}
```



iOS 侧

①、如果直接使用了 FusionViewController 作为 Flutter 容器

```swift
let fusionVc = FusionViewController(routeName: name, routeArguments: arguments)
let channel = FlutterMethodChannel(name: "自定义的channel名", binaryMessenger: fusionVc.binaryMessenger)
channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
    
}
```

```swift
deinit {
  channel?.setMethodCallHandler(nil)
  channel = nil
}
```

### 

②、如果创建一个继承自 FusionViewController 的 ViewController 作为 Flutter 容器

既可以按照①中的方式创建channel，也可以实现 FusionMessengerProvider 协议，在协议方法中创建 Channel

```swift
class CustomViewController : FusionViewController, FusionMessengerProvider {
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

> BasicMessageChannel 和 EventChannel 使用也是类似

### 6、生命周期
支持 `页面模式` 下监听 Flutter 页面的生命周期。
- ①、在需要监听生命周期页面的 State 中 `implements` PageLifecycleListener
- ②、在 didChangeDependencies 中注册监听
- ③、在 dispose 中注销监听
```dart
class LifecyclePage extends StatefulWidget {
  const LifecyclePage({Key? key}) : super(key: key);

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage>
    implements PageLifecycleListener {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PageLifecycleBinding.instance.register(this);
  }

  @override
  void onPageVisible() {}

  @override
  void onPageInvisible() {}

  @override
  void onForeground() {}

  @override
  void onBackground() {}

  @override
  void dispose() {
    super.dispose();
    PageLifecycleBinding.instance.unregister(this);
  }
}
```
PageLifecycleListener 生命周期回调函数：
- onForeground: 应用进入前台会被调用，所有注册了生命周期监听的页面都会收到
- onBackground: 应用退到后台会被调用，所有注册了生命周期监听的页面都会收到
- onPageVisible: 该 Flutter 页面可见时被调用，如：从 Native 页面或其他 Flutter 页面 `push` 到该 Flutter 页面时；从 Native 页面或其他 Flutter 页面 `pop` 到该 Flutter 页面时；但当应用进入前台时不会被调用，与 iOS 的 `viewDidAppear` 类似，与 Android 的 `onResume` 稍有差异
- onPageInvisible: 该 Flutter 页面不可见时被调用，如：从该 Flutter 页面 `push` 到 Native 页面或其他 Flutter 页面时；如从该 Flutter 页面 `pop` 到 Native 页面或其他 Flutter 页面时；但当应用退到后台时不会被调用，与 iOS 的 `viewDidDisappear` 类似，与 Android 的 `onStop` 稍有差异

### 7、页面通信
支持多种情况下页面消息传递：
- Flutter -> Flutter
- Flutter -> Native 
- Native -> Flutter
- Native -> Native

#### 注册消息监听
Flutter侧
- ①、在需要监听消息的页面的 State 中 `implements` PageNotificationListener，并复写 `onReceive` 方法，该方法可收到发送过来的消息
- ②、在 didChangeDependencies 中注册监听
- ③、在 dispose 中注销监听
```dart
class TestPage extends StatefulWidget {

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> implements PageNotificationListener {

  @override
  void onReceive(String msgName, Map<String, dynamic>? msgBody) {
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PageNotificationBinding.instance.register(this);
  }

  @override
  void dispose() {
    super.dispose();
    PageNotificationBinding.instance.unregister(this);
  }
}
```

Android侧
- 在需要监听页面消息的 Activity 中 实现 PageNotificationListener 接口，并复写 `onReceive` 方法，该方法可收到发送过来的消息

iOS侧
- 在需要监听页面消息的 ViewController（不支持子VC） 中 实现 PageNotificationListener 协议，并复写 `onReceive` 方法，该方法可收到发送过来的消息

#### 发送消息
三端均可使用`FusionNavigator` 的 `sendMessage` 方法来发送消息。

### 8、返回拦截

在纯 Flutter 开发中可以使用`WillPopScope`组件拦截返回操作，Fusion 也完整支持该功能，使用方式与在纯 Flutter 开发完全一致，此外使用`FusionNavigator.maybePop`的操作也可被`WillPopScope`组件拦截。

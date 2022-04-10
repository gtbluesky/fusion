# Fusion
[![pub package](https://img.shields.io/pub/v/fusion.svg)](https://pub.dev/packages/fusion)

## 简介

Fusion 是新一代的混合管理框架，用于 Flutter 与 Native 页面统一管理，并支持页面通信、页面生命周期监听等功能。

Fusion 使用了 Flutter 新的导航框架 Navigator2.0，这使得 Fusion 可以更加灵活对 Flutter 路由栈进行管理。此外 Fusion 基于 FlutterEngineGroup 实现多 Engine，通过 FlutterEngineGroup 来创建新的 Engine，Flutter 官方宣称内存损耗仅占 180K，其本质是使 Engine 可以共享 GPU 上下文、字形和 isolate group snapshot，从而实现了更快的初始速度和更低的内存占用。这样在保证了性能的前提下混合栈的管理也变得更加便捷。

不像其他类似框架，随着 Flutter 版本的更新往往需要对框架本身进行版本适配工作，如果开发者维护不及时就会导致整个项目都无法使用新版 Flutter， Fusion 未对 Flutter Framework 层进行 Hook，较好的兼容性使得使用者可以更加从容地升级 Flutter。

设计严格遵循以下原则：

- 轻量化
- 最小侵入
- 三端一致API



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
final Map<String, PageFactory> routeMap = {
  '/test': (arguments) => TestPage(arguments: arguments),
  '/404': (arguments) => UnknownPage(arguments: arguments),
};
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
        let navController = self.window?.rootViewController as? UINavigationController
        let fusionVc = CustomViewController(routeName: name, routeArguments: arguments)
        GeneratedPluginRegistrant.register(with: fusionVc.engine!)
        navController?.pushViewController(fusionVc, animated: true)
    }
}
```

### 2、Flutter 容器

#### 页面模式

Android 使用 FusionActivty，启动 FusionActivty（或其子类）时需要使用 Fusion 提供的 `buildFusionIntent` 方法。

iOS 使用 FusionViewController，可以直接使用，也可通过继承其创建新的 ViewController。


#### 子页面模式

Android 使用 FusionFragment 支持子页面模式，创建 FusionFragment 对象需要使用 `FusionFragment.buildFragment` 方法。

iOS 使用 FusionViewController 并传入 `childMode: true` 以支持子页面模式。

另外与其他类似框架相比，Fusion 支持在同一父页面下可使用多个 Flutter 子页面。


### 3、路由API（FusionNavigator）

✅ push：指定页入栈，支持获取返回值

✅ pop：栈顶页出栈，支持设置返回值

**TODO**

❎ popTo

❎ remove

❎ replace



### 4、Flutter Plugin 注册

如果 Flutter Module 中依赖了 Flutter Plugin，需要按照以下步骤进行注册。

Android 侧

在 AndroidManifest.xml 加入以下代码，Flutter 框架会自动注册插件

```xml
<manifest>
    ...
    <application>
        ...
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

iOS 侧

每次创建 FusionViewContoller 对象都要通过以下代码注册

```swift
let fusionVc = FusionViewController(routeName: name, routeArguments: arguments)
GeneratedPluginRegistrant.register(with: fusionVc.engine!)
```



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
}
```



②、如果使用的是 FusionActivity 容器，则需要创建一个新的 Activity 并继承 FusionActivity 并实现 FusionMessengerProvider 接口，在接口方法中创建 Channel

```kotlin
class CustomActivity : FusionActivity(), FusionMessengerProvider {
  
    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        val channel = MethodChannel(binaryMessenger, "自定义的channel名")
        channel.setMethodCallHandler { call, result -> 
            
        }
    }
}
```



iOS 侧

①、如果直接使用了 FusionViewController 作为 Flutter 容器

```swift
let fusionVc = FusionViewController(routeName: name, routeArguments: arguments)
let channel = FlutterMethodChannel(name: "自定义的channel名", binaryMessenger: fusionVc.binaryMessenger)
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
   				//根据call.method匹配路由
        }
```



②、如果创建一个继承自 FusionViewController 的 ViewController 作为 Flutter 容器

既可以按照①中的方式创建channel，也可以实现 FusionMessengerProvider 协议，在协议方法中创建 Channel

```swift
class CustomViewController : FusionViewController, FusionMessengerProvider {
    func configureFlutterChannel(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "自定义的channel名", binaryMessenger: binaryMessenger)
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
   				//根据call.method匹配路由
        }
    }
}
```

> BasicMessageChannel 和 EventChannel 使用也是类似。另外务必确保 Flutter 和 Native 使用的 Channel类型统一。

需要注意的是，自行创建的 Channel，Android 需要在 Activity 的 onDestroy、iOS 需要在 ViewController 的析构函数中对其置空，避免可能的内存泄漏。

Android 侧

```kotlin
override fun onDestroy() {
  super.onDestroy()
  channel?.setMethodCallHandler(null)
  channle = null
}
```

iOS 侧

```swift
deinit {
  channel?.setMethodCallHandler(nil)
  channel = nil
}
```

### 6、生命周期
支持 `页面模式` 下监听 Flutter 页面的生命周期。
- ①、在需要监听生命周期页面的 State 中 `implements` PageLifecycleObserver
- ②、在 didChangeDependencies 中注册监听
- ③、在 dispose 中注销监听
```dart
class LifecyclePage extends StatefulWidget {
  const LifecyclePage({Key? key}) : super(key: key);

  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage>
    implements PageLifecycleObserver {
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
PageLifecycleObserver 生命周期回调函数：
- onForeground: 应用进入前台会被调用，所有注册了生命周期监听的页面都会收到
- onBackground: 应用退到前台会被调用，所有注册了生命周期监听的页面都会收到
- onPageVisible: 该 Flutter 页面可见时被调用，如：从 Native 页面或其他 Flutter 页面 `push` 到该 Flutter 页面时；从 Native 页面或其他 Flutter 页面 `pop` 到该 Flutter 页面时；但当应用进入前台时不会被调用，与 iOS 的 `viewDidAppear` 类似，与 Android 的 `onResume` 稍有差异
- onPageInvisible: 该 Flutter 页面不可见时被调用，如：从该 Flutter 页面 `push` 到 Native 页面或其他 Flutter 页面时；如从该 Flutter 页面 `pop` 到 Native 页面或其他 Flutter 页面时；但当应用退到后台时不会被调用，与 iOS 的 `viewDidDisappear` 类似，与 Android 的 `onStop` 稍有差异
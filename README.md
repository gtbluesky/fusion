# Fusion
[![pub package](https://img.shields.io/pub/v/fusion.svg)](https://pub.dev/packages/fusion)

## 简介

Fusion 是新一代的混合栈管理框架，用于 Flutter 与 Native 页面统一管理，并支持页面通信、页面生命周期监听等功能。Fusion 即 `融合`，我们的设计初衷就是帮助开发者在使用 Flutter 与 Native 进行混合开发时尽量感受不到两者的隔阂，提升开发体验。

Fusion 采用引擎复用方案，在 Flutter 与 Native 页面多次跳转情况下，APP 始终仅有一份 FlutterEngine 实例，因此拥有更好的性能和更低的内存占用。

不像其他类似框架，随着 Flutter 版本的更新往往需要对框架本身进行版本适配工作，如果开发者维护不及时就会导致整个项目都无法使用新版 Flutter，而 Fusion 优秀的兼容性使得使用者可以更加从容地升级 Flutter 版本，目前支持 Flutter SDK 从 2.x 到 3.x 的全部版本。

Fusion 更加注重细节的处理，着力解决了其他类似框架中普遍存在的问题，如：Flutter 容器与 Native 容器跳转时状态栏图标颜色可能出现显示不正确的问题； 混合开发时当栈顶是 Flutter 页面时进入到任务界面其应用名称不显示的问题等。

Fusion 彻底解决了混合栈框架普遍存在的黑屏、白屏、闪屏等疑难杂症。

此外，Fusion 也是目前仅有的支持混合开发时应用在后台被系统回收后Flutter页面可正常恢复的混合栈框架。

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
  kUnknownRoute: (arguments) => UnknownPage(arguments: arguments),
};
```
P.S: `kUnknownRoute`表示未定义路由

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
        // 可在 arguments 中存放参数判断是否需要打开透明页面
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
      Fusion.instance.install(self)
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
        // 可在 arguments 中存放参数判断是否需要打开透明页面
        guard let name = name else {
            return
        }
        let nc = self.window?.rootViewController as? UINavigationController
        let fusionVc = CustomViewController(routeName: name, routeArguments: arguments)
        // 可在 arguments 中存放参数判断是 push 还是 present
        nc?.pushViewController(fusionVc, animated: true)
    }
}
```

### 2、Flutter 容器

#### 普通页面模式

Android 通过 `FusionActivity`（或其子类） 创建 Flutter 容器，启动容器时需要使用 Fusion 提供的 `buildFusionIntent` 方法，其中参数 `transparent` 需设为 false。其 xml 配置参考如下：

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



iOS 通过 `FusionViewController` （或其子类）创建 Flutter 容器，`push` 和 `present` 均支持。FusionViewController 默认隐藏了 UINavigationController。

在 iOS 中需要处理原生右滑退出手势和 Flutter 手势冲突的问题，解决方法也很简单：只需在自定义的 Flutter 容器中实现 `FusionPopGestureHandler` 并在对应方法中启用或者关闭原生手势即可，这样可以实现如果当前 Flutter 容器存在多个 Flutter 页面时，右滑手势是退出 Flutter 页面，而当 Flutter 页面只有一个时则右滑退出 Flutter 容器。

```swift
    // 启用原生手势
    func enablePopGesture() {
        // 以下代码仅做演示，不可直接照搬，需根据APP实际情况自行实现
        let nc = navigationController
        if nc == nil {
            return
        }
        if nc?.isNavigationBarHidden == false {
            return
        }
        nc?.addPopGesture()
    }

    // 关闭原生手势
    func disablePopGesture() {
        // 以下代码仅做演示，不可直接照搬，需根据APP实际情况自行实现
        let nc = navigationController
        if nc == nil {
            return
        }
        if nc?.isNavigationBarHidden == false {
            return
        }
        nc?.removePopGesture()
    }
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

使用方式与普通页面模式相似，区别如下：

```swift
let fusionVc = CustomViewController(routeName: name, routeArguments: arguments, transparent: true)
navController?.present(fusionVc, animated: false)
```

同时Flutter页面背景也需要设置为透明



#### 子页面模式

子页面模式是指一个或多个 Flutter 页面同时嵌入到 Native 容器中的场景，如：使用Tab切换Flutter和原生页面，Fusion 支持多个 Flutter 页面嵌入同一个 Native 容器中。

Android 侧

使用 FusionFragment 以支持子页面模式，创建 FusionFragment 对象需要使用 `buildFusionFragment` 方法。

iOS 侧

与页面模式一样使用 FusionViewController 



#### 自定义容器背景色

默认情况下容器的背景为白色，这是因为考虑到绝大多数的页面都是使用白色背景，但如果打开的首个Flutter页面的背景是其他颜色，比如夜间模式下页面为深灰色，此时是为了更好的视觉效果，可以自定义容器的背景色与首个Flutter页面的背景色一致。

Android 侧

在 `buildFusionIntent` 和 `buildFusionFragment`方法中参数 `backgroundColor` 设为所需背景色

iOS 侧

在创建 FusionViewController （或其子类）对象时，参数 `backgroundColor` 设为所需背景色



### 3、路由API（FusionNavigator）

open：打开新Flutter容器并将对应路由入栈，Native页面跳转Flutter页面使用该API

push：在当前Flutter容器中将对应路由入栈，Navigator.pushNamed 与之等同

pop：在当前Flutter容器中将栈顶路由出栈，Navigator.pop 与之等同

maybePop：在当前Flutter容器中将栈顶路由出栈，可被WillPopScope拦截

replace：在当前Flutter容器中将栈顶路由替换为对应路由，Navigator.pushReplacementNamed 与之等同

remove：在当前Flutter容器中移除对应路由

路由跳转与关闭等操作既可使用`FusionNavigator`的 API，也可使用`Navigator`中与之对应的API（仅上述提到的部分），另外连续`pop`操作，前一个`pop`需要`await`，即：
```dart
await FusionNavigator.instance.pop();
FusionNavigator.instance.pop();
```

### 4、Flutter Plugin 注册

框架内部会自动注册插件，无须手动调用 `GeneratedPluginRegistrant.registerWith` 进行注册

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

在自实现的 FusionActivity 、 FusionFragmentActivity、FusionFragment 上实现 FusionMessengerHandler 接口，在 configureFlutterChannel 中创建 Channel，在 releaseFlutterChannel 释放 Channel

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

> BasicMessageChannel 和 EventChannel 使用也是类似

P.S.: 与容器相关的方法是与容器生命周期绑定的，如果容器不可见或者销毁了则无法收到Channel消息。

### 6、生命周期
目前仅支持 `页面模式` 下监听 Flutter 页面的生命周期。
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
- onPageVisible: 该 Flutter 页面可见时被调用，如：从 Native 页面或其他 Flutter 页面 `push` 到该 Flutter 页面时；从 Native 页面或其他 Flutter 页面 `pop` 到该 Flutter 页面时；应用进入前台时也会被调用。
- onPageInvisible: 该 Flutter 页面不可见时被调用，如：从该 Flutter 页面 `push` 到 Native 页面或其他 Flutter 页面时；如从该 Flutter 页面 `pop` 到 Native 页面或其他 Flutter 页面时；应用退到后台时也会被调用。

### 7、全局通信
支持消息在应用全局中的传递，不论是 Native 还是 Flutter 皆可接收和发送。
#### 注册消息监听
Flutter侧
- ①、在需要监听消息的 Widget（支持任意Widget） 的 State 中 `implements` FusionNotificationListener，并复写 `onReceive` 方法，该方法可收到发送过来的消息
- ②、在 didChangeDependencies 中注册监听
- ③、在 dispose 中注销监听
```dart
class TestPage extends StatefulWidget {

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> implements FusionNotificationListener {

  @override
  void onReceive(String name, Map<String, dynamic>? body) {
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FusionNotificationBinding.instance.register(this);
  }

  @override
  void dispose() {
    super.dispose();
    FusionNotificationBinding.instance.unregister(this);
  }
}
```

Android侧
- ①、在需要监听消息的 Activity 或 Fragment 中实现 FusionNotificationListener 接口，并复写 `onReceive` 方法，该方法可收到发送过来的消息
- ②、在适当时机使用 `FusionNotificationBinding` 的 `register` 方法注册监听
- ③、在适当时机使用 `FusionNotificationBinding` 的 `unregister` 方法注销监听，若不手动注销，在该 Activity 或 Fragment 被销毁后 Fusion 内部则会自动注销

iOS侧
- ①、在需要监听消息的 UIViewController 中实现 FusionNotificationListener 协议，并复写 `onReceive` 方法，该方法可收到发送过来的消息
- ②、在适当时机使用 `FusionNotificationBinding` 的 `register` 方法注册监听
- ③、在适当时机使用 `FusionNotificationBinding` 的 `unregister` 方法注销监听，若不手动注销，在该 UIViewController 被销毁后 Fusion 内部则会自动注销

#### 发送消息
三端均可使用`FusionNavigator` 的 `sendMessage` 方法来发送消息。

### 8、返回拦截

在纯 Flutter 开发中可以使用`WillPopScope`组件拦截返回操作，Fusion 也完整支持该功能，使用方式与在纯 Flutter 开发完全一致，此外使用`FusionNavigator.maybePop`的操作也可被`WillPopScope`组件拦截。

### 9、状态恢复

Fusion 支持 Android 和 iOS 平台 APP 被回收后 Flutter 路由的恢复

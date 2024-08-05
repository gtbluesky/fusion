## 4.5.0

* Changes `FusionAppLifecycleListener` and `FusionPageLifecycleListener` from class to mixin.
* Adds `FusionNavigator.topRouteName` method.

## 4.4.0

* Adds `FusionNavigationController` class on iOS.
* Fixes some known bugs.

## 4.3.2

* Adds the `Fusion.getTopActivity` method on Android.

## 4.3.1

* Fixes some known bugs.

## 4.3.0

* Adds `popUntil`、`pushAndClear` and `hasRouteByName` methods in `FusionNavigator`.

## 4.2.0

* **BREAKING CHANGE**: Changes the class `FusionPageLifecycleBinding` to `FusionPageLifecycleManager`, changes the class `FusionAppLifecycleBinding` to `FusionAppLifecycleManager`, changes the class `FusionNotificationBinding` to `FusionEventManager`.

## 4.1.0

* Solves the problem of white screen or black screen when switching pages.

## 4.0.0

* Adapts to HarmonyOS Next/OpenHarmony.
* **BREAKING CHANGE**: Changes the parameter `arguments` to `args` in some functions.
* **BREAKING CHANGE**: Changes the class `PageLifecycleListener` to `FusionPageLifecycleListener`, changes the class `PageLifecycleBinding` to `FusionPageLifecycleBinding`.
* **BREAKING CHANGE**: Combines `push` and `open` method into a new `push` method. For specific usage, please refer to README.
* **BREAKING CHANGE**: `sendMessage` is no longer limited to Activity/Fragment/UIViewController/State, and the range of message delivery can be selected through `FusionNotificationType`. For specific usage, please refer to README.
* Provides global context in `FusionNavigator`.

## 3.1.1

* Fixes some known bugs.

## 3.1.0

* Adds global lifecycle observer.
* Fixes some known bugs.
* Updates minimum supported SDK version to Flutter 3.0.0/Dart 2.17.0.

## 3.0.7

* Adjust the strategy of Flutter's frame scheduling.

## 3.0.6

* Adjust display effect when view's size has changed on iOS side.

## 3.0.5

* Dialog can use `Navigator.pop` to dismiss.

## 3.0.4

* Fixes a compilation error on Flutter 3.0+.
* Removes all objective-c codes.

## 3.0.3

* Adds a builder option in FusionApp.
* Removes iOS's pop gesture function in FusionNavigator.

## 3.0.2

* Exposes iOS's pop gesture function in FusionNavigator.

## 3.0.1

* Fixes memory leak caused by using `PlatformView` on Android.
* Fixes some known bugs.

## 3.0.0

* BREAKING CHANGE: Reused engine is supported in all modes.

## 2.0.7

* Adjust global notification.

## 2.0.6

* Fixes white frame shown when flutter transparent container launched firstly.

## 2.0.5

* Fixes some known bugs.

## 2.0.4

* Fixes some known bugs.

## 2.0.3

* Fixes some known bugs.

## 2.0.2

* Fixes memory leak on iOS platform.
* Fixes replace method.

## 2.0.1

* Exposes Fusion's `defaultEngine` instance.

## 2.0.0

* BREAKING CHANGE: Change to reused engine project.

## 1.1.8

* Exposes `FlutterEngineGroup` instance.

## 1.1.7

* Fixes some known bugs.

## 1.1.6

* Fixes some known bugs.

## 1.1.5

* WillPopScope can be used；
* Fixes application name is empty in Android's app switcher within hybrid mode.

## 1.1.4

* Fixes some known bugs.

## 1.1.3

* Adds replace function in FusionNavigator.

## 1.1.2

* Flutter Plugins are registered automatically by Fusion.

## 1.1.1

* Fixes some known bugs.

## 1.1.0

* Adds the ability of communication with flutter and native pages.

## 1.0.9

* Adds custom prompt page when the route isn't in route map.
* Adds custom duration for page transition animation.

## 1.0.8

* Fixes the bug 'The Navigator.pages must not be empty to use the Navigator.pages API' when debugging.

## 1.0.7

* Adds adaptive pop gesture for iOS.

## 1.0.6

* Improve compatibility for iOS.

## 1.0.5

* Add FusionFragmentActivity for Android.

## 1.0.4

* Modify cocopods configuration.

## 1.0.3

* Fixes some known bugs.

## 1.0.2

* Adds lifecycle observer for flutter pages.
* Fixes some known bugs.

## 1.0.1

* Adds support for child mode.
* Fixes some known bugs.

## 1.0.0

* Initial release.
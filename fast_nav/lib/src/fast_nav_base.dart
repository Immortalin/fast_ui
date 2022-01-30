import 'dart:developer' as developer;
import 'package:fast_nav/src/exceptions.dart';
import 'package:flutter/material.dart';

/// Contextless navigator
class FastNav {
  FastNav._();

  static const _rootNavigatorName = '_rootNavigator';
  static final _navigatorKeys = <String, GlobalKey<NavigatorState>>{};
  static final _navigationStacks = <String, List<Route>>{};

  /// Register the root navigator with [FastNav]
  ///
  /// Call in the [MaterialApp] constructor
  static GlobalKey<NavigatorState> init([GlobalKey<NavigatorState>? key]) {
    return registerNavigator(_rootNavigatorName, key: key);
  }

  /// Register a nested navigator with [FastNav]
  static GlobalKey<NavigatorState> registerNavigator(
    String name, {
    GlobalKey<NavigatorState>? key,
  }) {
    return _navigatorKeys[name] = key ?? GlobalKey<NavigatorState>();
  }

  static void _checkInit({
    required String navigatorName,
    required bool preventDuplicates,
  }) {
    if (!_navigatorKeys.containsKey(navigatorName)) {
      throw NavigatorNotRegistered(
        navigatorName:
            navigatorName == _rootNavigatorName ? null : navigatorName,
      );
    }
    if (preventDuplicates && !_navigationStacks.containsKey(navigatorName)) {
      throw NavigatorObserverNotRegistered(
        navigatorName:
            navigatorName == _rootNavigatorName ? null : navigatorName,
      );
    }
  }

  static void _anonymousDuplicatePreventionCheck(String? lastRouteName) {
    if (lastRouteName == '/') {
      developer.log(
        'Anonymous duplicate page prevention will not work for root page',
        name: 'FastNav',
      );
    }
  }

  static NavigatorState _getNavigatorState(String navigatorName) {
    return _navigatorKeys[navigatorName]!.currentState!;
  }

  //* Common navigation methods

  /// Pop the current page
  static void pop<T extends Object?>({
    String navigatorName = _rootNavigatorName,
    T? result,
  }) {
    _checkInit(navigatorName: navigatorName, preventDuplicates: false);
    return _getNavigatorState(navigatorName).pop<T>(result);
  }

  /// Whether the navigator can be popped
  static bool canPop({String navigatorName = _rootNavigatorName}) {
    _checkInit(navigatorName: navigatorName, preventDuplicates: false);
    return _getNavigatorState(navigatorName).canPop();
  }

  //* Anonymous navigation

  /// Navigate to an anonymous page route
  ///
  /// [preventDuplicates] will not work for [MaterialApp.home]
  static Future<T?> push<T extends Object?>(
    Widget page, {
    String navigatorName = _rootNavigatorName,
    bool preventDuplicates = false,
    RouteSettings settings = const RouteSettings(),
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    _checkInit(
      navigatorName: navigatorName,
      preventDuplicates: preventDuplicates,
    );
    settings = _patchAnonymousRouteSettings(settings, page);
    if (preventDuplicates) {
      final lastRouteName =
          _navigationStacks[navigatorName]!.last.settings.name;
      _anonymousDuplicatePreventionCheck(lastRouteName);
      if (lastRouteName == settings.name) {
        return Future.value();
      }
    }
    return _getNavigatorState(navigatorName).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Replace the current page with a new anonymous page route
  ///
  /// [preventDuplicates] will not work for [MaterialApp.home]
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    String navigatorName = _rootNavigatorName,
    bool preventDuplicates = false,
    RouteSettings settings = const RouteSettings(),
    bool maintainState = true,
    bool fullscreenDialog = false,
    TO? result,
  }) {
    _checkInit(
      navigatorName: navigatorName,
      preventDuplicates: preventDuplicates,
    );
    settings = _patchAnonymousRouteSettings(settings, page);
    if (preventDuplicates) {
      final lastRouteName =
          _navigationStacks[navigatorName]!.last.settings.name;
      _anonymousDuplicatePreventionCheck(lastRouteName);
      if (lastRouteName == settings.name) {
        return Future.value();
      }
    }
    return _getNavigatorState(navigatorName).pushReplacement<T, TO>(
      MaterialPageRoute<T>(
        builder: (_) => page,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
      result: result,
    );
  }

  /// Remove pages until [predicate] returns true and push a new anonymous page route
  ///
  /// [preventDuplicates] will not work for [MaterialApp.home]
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    Widget page,
    bool Function(Route<dynamic> route) predicate, {
    String navigatorName = _rootNavigatorName,
    bool preventDuplicates = false,
    RouteSettings settings = const RouteSettings(),
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    _checkInit(
      navigatorName: navigatorName,
      preventDuplicates: preventDuplicates,
    );
    settings = _patchAnonymousRouteSettings(settings, page);
    if (preventDuplicates) {
      final lastRouteName =
          _navigationStacks[navigatorName]!.last.settings.name;
      _anonymousDuplicatePreventionCheck(lastRouteName);
      if (lastRouteName == settings.name) {
        return Future.value();
      }
    }
    return _getNavigatorState(navigatorName).pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
      predicate,
    );
  }

  /// Remove all pages and push a new anonymous page route
  ///
  /// [preventDuplicates] will not work for [MaterialApp.home]
  static Future<T?> pushAndRemoveAll<T extends Object?>(
    Widget page, {
    String navigatorName = _rootNavigatorName,
    bool preventDuplicates = false,
    RouteSettings settings = const RouteSettings(),
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    _checkInit(
      navigatorName: navigatorName,
      preventDuplicates: preventDuplicates,
    );
    settings = _patchAnonymousRouteSettings(settings, page);
    if (preventDuplicates) {
      final lastRouteName =
          _navigationStacks[navigatorName]!.last.settings.name;
      _anonymousDuplicatePreventionCheck(lastRouteName);
      if (lastRouteName == settings.name) {
        return Future.value();
      }
    }
    return _getNavigatorState(navigatorName).pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      ),
      (_) => false,
    );
  }

  //* Named navigation

  /// Navigate to a named page route
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    String navigatorName = _rootNavigatorName,
    bool preventDuplicates = false,
    Object? arguments,
  }) {
    _checkInit(
      navigatorName: navigatorName,
      preventDuplicates: preventDuplicates,
    );
    if (preventDuplicates &&
        _navigationStacks[navigatorName]!.last.settings.name == routeName) {
      return Future.value();
    }
    return _getNavigatorState(navigatorName).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replace the current page with a named page route
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    String navigatorName = _rootNavigatorName,
    bool preventDuplicates = false,
    TO? result,
    Object? arguments,
  }) {
    _checkInit(
      navigatorName: navigatorName,
      preventDuplicates: preventDuplicates,
    );
    if (preventDuplicates &&
        _navigationStacks[navigatorName]!.last.settings.name == routeName) {
      return Future.value();
    }
    return _getNavigatorState(navigatorName).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Remove pages until [predicate] returns true and push a named page route
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    bool Function(Route<dynamic> route) predicate, {
    String navigatorName = _rootNavigatorName,
    bool preventDuplicates = false,
    Object? arguments,
  }) {
    _checkInit(
      navigatorName: navigatorName,
      preventDuplicates: preventDuplicates,
    );
    if (preventDuplicates &&
        _navigationStacks[navigatorName]!.last.settings.name == newRouteName) {
      return Future.value();
    }
    return _getNavigatorState(navigatorName).pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  /// Remove all pages and push a named page route
  static Future<T?> pushNamedAndRemoveAll<T extends Object?>(
    String newRouteName, {
    String navigatorName = _rootNavigatorName,
    bool preventDuplicates = false,
    Object? arguments,
  }) {
    _checkInit(
      navigatorName: navigatorName,
      preventDuplicates: preventDuplicates,
    );
    if (preventDuplicates &&
        _navigationStacks[navigatorName]!.last.settings.name == newRouteName) {
      return Future.value();
    }
    return _getNavigatorState(navigatorName).pushNamedAndRemoveUntil<T>(
      newRouteName,
      (_) => false,
      arguments: arguments,
    );
  }

  //* Internal convenience methods

  /// Patch anonymous page [RouteSettings] to always have a name
  static RouteSettings _patchAnonymousRouteSettings(
    RouteSettings settings,
    Widget page,
  ) {
    if (settings.name == null) {
      return settings.copyWith(name: page.runtimeType.toString());
    } else {
      return settings;
    }
  }
}

/// A [NavigatorObserver] that informs [FastNav] of navigation events
class FastNavObserver extends NavigatorObserver {
  /// The name of the navigator to observe
  final String navigatorName;

  /// Create a new [FastNavObserver] for the given [navigatorName]
  FastNavObserver([this.navigatorName = FastNav._rootNavigatorName]) {
    FastNav._navigationStacks[navigatorName] = [];
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    FastNav._navigationStacks[navigatorName]!.removeLast();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    FastNav._navigationStacks[navigatorName]!.add(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    FastNav._navigationStacks[navigatorName]!.remove(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) {
      final index = FastNav._navigationStacks[navigatorName]!.indexOf(oldRoute);
      if (newRoute != null) {
        FastNav._navigationStacks[navigatorName]![index] = newRoute;
      } else {
        FastNav._navigationStacks[navigatorName]!.removeAt(index);
      }
    } else if (newRoute != null) {
      FastNav._navigationStacks[navigatorName]!.add(newRoute);
    }
  }
}

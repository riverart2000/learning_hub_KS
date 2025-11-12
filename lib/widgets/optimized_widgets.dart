import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

/// Mixin for optimizing widget rebuilds and memory usage.
/// 
/// Usage:
/// ```dart
/// class MyWidget extends StatefulWidget with WidgetOptimizationMixin {
///   // ... widget implementation
/// }
/// ```
mixin WidgetOptimizationMixin on Widget {
  /// Returns a unique cache key for this widget instance
  String getCacheKey() {
    return '${runtimeType}_${key ?? hashCode}';
  }
}

/// Base class for optimized StatelessWidget with const constructor support
abstract class OptimizedStatelessWidget extends StatelessWidget {
  const OptimizedStatelessWidget({super.key});
  
  @override
  @protected
  Widget build(BuildContext context);
}

/// Base class for optimized StatefulWidget with lifecycle logging
abstract class OptimizedStatefulWidget extends StatefulWidget {
  const OptimizedStatefulWidget({super.key});
  
  /// Override to enable lifecycle logging for debugging
  bool get enableLifecycleLogging => false;
}

/// Base State class with performance optimizations
abstract class OptimizedState<T extends OptimizedStatefulWidget> extends State<T> {
  bool _mounted = false;
  
  @override
  void initState() {
    super.initState();
    _mounted = true;
    
    if (widget.enableLifecycleLogging) {
      AppLogger.debug('initState', tag: _getTag());
    }
  }

  @override
  void dispose() {
    _mounted = false;
    
    if (widget.enableLifecycleLogging) {
      AppLogger.debug('dispose', tag: _getTag());
    }
    
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.enableLifecycleLogging) {
      AppLogger.debug('didUpdateWidget', tag: _getTag());
    }
  }

  /// Safely calls setState only if the widget is still mounted
  void safeSetState(VoidCallback fn) {
    if (_mounted && mounted) {
      setState(fn);
    } else {
      AppLogger.warning(
        'Attempted setState on unmounted widget',
        tag: _getTag(),
      );
    }
  }

  String _getTag() => '${widget.runtimeType}State';
  
  bool get isMountedSafely => _mounted && mounted;
}

/// Builder for conditionally rendering widgets to avoid unnecessary builds
class ConditionalBuilder extends StatelessWidget {
  final bool condition;
  final WidgetBuilder builder;
  final WidgetBuilder? fallbackBuilder;

  const ConditionalBuilder({
    super.key,
    required this.condition,
    required this.builder,
    this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return builder(context);
    } else if (fallbackBuilder != null) {
      return fallbackBuilder!(context);
    } else {
      return const SizedBox.shrink();
    }
  }
}

/// Cached widget builder to prevent unnecessary rebuilds
class CachedBuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final bool shouldRebuild;

  const CachedBuilder({
    super.key,
    required this.builder,
    this.shouldRebuild = false,
  });

  @override
  State<CachedBuilder> createState() => _CachedBuilderState();
}

class _CachedBuilderState extends State<CachedBuilder> {
  Widget? _cachedWidget;

  @override
  Widget build(BuildContext context) {
    if (_cachedWidget == null || widget.shouldRebuild) {
      _cachedWidget = widget.builder(context);
    }
    return _cachedWidget!;
  }
}

/// Lazy loading wrapper for heavy widgets
class LazyLoadWrapper extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final Duration delay;
  final Widget? placeholder;

  const LazyLoadWrapper({
    super.key,
    required this.builder,
    this.delay = const Duration(milliseconds: 100),
    this.placeholder,
  });

  @override
  State<LazyLoadWrapper> createState() => _LazyLoadWrapperState();
}

class _LazyLoadWrapperState extends State<LazyLoadWrapper> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  void _scheduleLoad() {
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return widget.builder(context);
    }
    
    return widget.placeholder ?? const SizedBox.shrink();
  }
}

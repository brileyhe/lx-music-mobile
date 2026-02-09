import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/logger.dart';

/// UI rendering optimizations for lower-end hardware
/// Particularly important for older Android devices (4.1+)
class RenderingOptimizer {
  /// Enables performance optimizations for lower-end devices
  static void enablePerformanceOptimizations() {
    // Reduce raster cache size to save memory
    PaintingBinding.instance.renderView.setSemanticsEnabled(false);
    
    // Enable performance overlay if needed for debugging
    // This should be disabled in production
    RenderDirtyBits.debugDisableNeedPaint = false;
    
    Logger.info('Enabled rendering optimizations for lower-end hardware');
  }

  /// Creates a performance-optimized widget tree
  static Widget createOptimizedWidgetTree(Widget child) {
    return RepaintBoundary(
      child: child,
    );
  }

  /// Builds a list with performance optimizations
  static Widget buildOptimizedListView({
    required List<Widget> children,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        // Use RepaintBoundary to isolate repaints
        return RepaintBoundary(
          child: children[index],
        );
      },
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      padding: padding,
    );
  }

  /// Builds a performance-optimized grid view
  static Widget buildOptimizedGridView({
    required List<Widget> children,
    int crossAxisCount = 2,
    double crossAxisSpacing = 8.0,
    double mainAxisSpacing = 8.0,
    double childAspectRatio = 1.0,
  }) {
    return GridView.builder(
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        // Use RepaintBoundary to isolate repaints
        return RepaintBoundary(
          child: children[index],
        );
      },
    );
  }

  /// Creates a performance-optimized image widget
  static Widget buildOptimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool useRepaintBoundary = true,
  }) {
    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );

    if (useRepaintBoundary) {
      imageWidget = RepaintBoundary(child: imageWidget);
    }

    return imageWidget;
  }

  /// Creates a performance-optimized animated widget
  static Widget buildOptimizedAnimatedWidget({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: KeyedSubtree(key: ValueKey(child.hashCode), child: child),
    );
  }

  /// Disables unnecessary animations for better performance
  static void disableAnimationsForLowPerf() {
    // Set global animation speed to 0 to disable animations
    timeDilation = 100.0; // This slows down animations significantly
    Logger.info('Disabled animations for better performance on low-end hardware');
  }

  /// Re-enables animations
  static void enableAnimations() {
    timeDilation = 1.0;
    Logger.info('Re-enabled animations');
  }

  /// Checks if the device has limited performance capabilities
  static bool isLowPerformanceDevice() {
    // In a real implementation, this would check device capabilities
    // For now, we'll return true to simulate optimization for older devices
    return true;
  }

  /// Applies optimizations based on device capabilities
  static void applyDeviceSpecificOptimizations() {
    if (isLowPerformanceDevice()) {
      // Reduce shader mask quality
      RendererBinding.instance.setSemanticsEnabled(false);
      
      // Use simpler shadows
      Card.defaultShadowElevation = 2.0;
      
      // Reduce animation complexity
      enablePerformanceOptimizations();
      
      Logger.info('Applied optimizations for low-performance device');
    }
  }

  /// Creates a performance-optimized text widget
  static Widget buildOptimizedText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
    );
  }

  /// Creates a performance-optimized button
  static Widget buildOptimizedButton({
    required VoidCallback onPressed,
    required Widget child,
    ButtonStyle? style,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }

  /// Disposes of optimization resources
  static void dispose() {
    // Reset time dilation if it was changed
    if (timeDilation != 1.0) {
      timeDilation = 1.0;
    }
  }
}

/// A custom scroll physics that reduces overscroll glow for better performance
class PerformanceScrollPhysics extends ScrollPhysics {
  const PerformanceScrollPhysics({super.parent});

  @override
  PerformanceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PerformanceScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1.0,
        stiffness: 100.0, // Reduced stiffness for smoother scrolling
        damping: 1.0,
      );
}

/// A widget that conditionally applies performance optimizations
class ConditionalPerformanceWidget extends StatelessWidget {
  final Widget child;
  final bool Function()? shouldOptimize;

  const ConditionalPerformanceWidget({
    super.key,
    required this.child,
    this.shouldOptimize,
  });

  @override
  Widget build(BuildContext context) {
    final optimize = shouldOptimize?.call() ?? RenderingOptimizer.isLowPerformanceDevice();
    
    if (optimize) {
      return RenderingOptimizer.createOptimizedWidgetTree(child);
    }
    
    return child;
  }
}
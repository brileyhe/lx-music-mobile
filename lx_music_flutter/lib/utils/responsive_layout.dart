import 'package:flutter/material.dart';

/// Defines screen size categories for responsive design
enum ScreenSize {
  small,    // Phones
  medium,   // Small tablets, large phones
  large,    // Tablets (7-8")
  extraLarge, // Large tablets (9-10"+)
}

/// Provides responsive layout utilities for different screen sizes
/// Specifically designed to support 8"-10" automotive displays
class ResponsiveLayout {
  /// Calculates the screen size category based on the shortest side
  static ScreenSize getScreenSize(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    
    if (shortestSide < 600) {
      return ScreenSize.small; // Phones
    } else if (shortestSide < 720) {
      return ScreenSize.medium; // Small tablets, large phones
    } else if (shortestSide < 900) {
      return ScreenSize.large; // Tablets (7-8")
    } else {
      return ScreenSize.extraLarge; // Large tablets (9-10"+)
    }
  }

  /// Gets responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(8.0);
      case ScreenSize.medium:
        return const EdgeInsets.all(12.0);
      case ScreenSize.large:
        return const EdgeInsets.all(16.0);
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(24.0);
    }
  }

  /// Gets responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return 8.0;
      case ScreenSize.medium:
        return 12.0;
      case ScreenSize.large:
        return 16.0;
      case ScreenSize.extraLarge:
        return 24.0;
    }
  }

  /// Gets responsive font size based on screen size
  static double getResponsiveFontSize(BuildContext context, {double baseSize = 16.0}) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return baseSize * 0.9;
      case ScreenSize.medium:
        return baseSize;
      case ScreenSize.large:
        return baseSize * 1.1;
      case ScreenSize.extraLarge:
        return baseSize * 1.2;
    }
  }

  /// Gets responsive icon size based on screen size
  static double getResponsiveIconSize(BuildContext context, {double baseSize = 24.0}) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return baseSize * 1.0;
      case ScreenSize.medium:
        return baseSize * 1.1;
      case ScreenSize.large:
        return baseSize * 1.2;
      case ScreenSize.extraLarge:
        return baseSize * 1.4;
    }
  }

  /// Gets responsive button height based on screen size
  static double getResponsiveButtonHeight(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return 48.0;
      case ScreenSize.medium:
        return 52.0;
      case ScreenSize.large:
        return 56.0;
      case ScreenSize.extraLarge:
        return 64.0;
    }
  }

  /// Gets responsive touch target size based on screen size
  /// Ensures accessibility for automotive use
  static double getResponsiveTouchTargetSize(BuildContext context) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.small:
        return 48.0; // Standard minimum
      case ScreenSize.medium:
        return 52.0;
      case ScreenSize.large:
        return 56.0;
      case ScreenSize.extraLarge:
        return 64.0; // Larger for automotive use
    }
  }
}

/// A widget that builds its content based on the current screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ScreenSize screenSize,
    BoxConstraints constraints,
  ) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(
          context,
          ResponsiveLayout.getScreenSize(context),
          constraints,
        );
      },
    );
  }
}

/// A responsive grid view that adapts to screen size
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        int crossAxisCount;
        
        switch (screenSize) {
          case ScreenSize.small:
            crossAxisCount = 2;
          case ScreenSize.medium:
            crossAxisCount = 3;
          case ScreenSize.large:
            crossAxisCount = 4;
          case ScreenSize.extraLarge:
            crossAxisCount = 5;
        }

        return GridView.builder(
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// A responsive list view that adapts to screen size
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.shrinkWrap = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize, constraints) {
        double itemHeight;
        
        switch (screenSize) {
          case ScreenSize.small:
            itemHeight = 64.0;
          case ScreenSize.medium:
            itemHeight = 72.0;
          case ScreenSize.large:
            itemHeight = 80.0;
          case ScreenSize.extraLarge:
            itemHeight = 96.0;
        }

        return ListView.separated(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: scrollController,
          shrinkWrap: shrinkWrap,
          padding: padding ?? ResponsiveLayout.getResponsivePadding(context),
          itemCount: children.length,
          separatorBuilder: (context, index) => SizedBox(
            height: scrollDirection == Axis.vertical 
                ? ResponsiveLayout.getResponsiveSpacing(context) 
                : 0,
            width: scrollDirection == Axis.horizontal 
                ? ResponsiveLayout.getResponsiveSpacing(context) 
                : 0,
          ),
          itemBuilder: (context, index) {
            return Container(
              height: scrollDirection == Axis.vertical ? itemHeight : null,
              width: scrollDirection == Axis.horizontal ? itemHeight : null,
              child: children[index],
            );
          },
        );
      },
    );
  }
}
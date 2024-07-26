import 'package:arche/arche.dart';
import 'package:flutter/material.dart';

class PageContainer extends StatelessWidget {
  final Widget? child;
  final String? title;

  const PageContainer({
    super.key,
    this.child,
    this.title,
  });

  PageContainer.scrollable({
    super.key,
    required List<Widget> children,
    EdgeInsets? padding,
    this.title,
  }) : child = ScrollableContainer(
          padding: padding,
          children: children,
        );

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainer,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: title == null
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                forceMaterialTransparency: true,
                title: Text(title!),
              ),
        body: Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 20),
          child: RRectCountainer(
            child: child,
          ),
        ),
      ),
    );
  }

  NavigationItem toItem({
    required Widget icon,
    Widget? selectedIcon,
    bool enabled = true,
    VerticalItemConfig? config,
  }) {
    return NavigationItem(
      icon: icon,
      label: title ?? "",
      page: this,
      selectedIcon: selectedIcon,
      vertical: config,
      enabled: enabled,
    );
  }
}

class ScrollableContainer extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;

  const ScrollableContainer({
    super.key,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}

class RRectCountainer extends StatelessWidget {
  final Widget? child;
  const RRectCountainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: SizedBox.expand(
        child: Align(
          alignment: Alignment.topLeft,
          child: child,
        ),
      ),
    );
  }
}

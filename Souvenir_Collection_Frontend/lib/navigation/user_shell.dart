import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell that hosts the StatefulNavigationShell for the main tabbed interface.
/// Each screen provides its own themed HeritageBottomNav, so this shell
/// simply renders the active branch without a duplicate navigation bar.
class UserShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const UserShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return navigationShell;
  }
}

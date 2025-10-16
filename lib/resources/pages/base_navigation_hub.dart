import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/feed_widget.dart';
import '/resources/widgets/upload_widget.dart';
import '/resources/widgets/saved_widget.dart';
import '/resources/widgets/profile_widget.dart';

class BaseNavigationHub extends NyStatefulWidget with BottomNavPageControls {
  static RouteView path = ("/base", (_) => BaseNavigationHub());

  BaseNavigationHub()
      : super(
            child: () => _BaseNavigationHubState(),
            stateName: path.stateName());

  /// State actions
  static NavigationHubStateActions stateActions =
      NavigationHubStateActions(path.stateName());
}

class _BaseNavigationHubState extends NavigationHub<BaseNavigationHub> {
  /// Layouts:
  /// - [NavigationHubLayout.bottomNav] Bottom navigation
  /// - [NavigationHubLayout.topNav] Top navigation
  /// - [NavigationHubLayout.journey] Journey navigation
  NavigationHubLayout? layout = NavigationHubLayout.bottomNav(
      // backgroundColor: Colors.white,
      );

  /// Should the state be maintained
  @override
  bool get maintainState => false;

  /// Navigation pages
  _BaseNavigationHubState()
      : super(() async {
          /// * Creating Navigation Tabs
          /// [Navigation Tabs] 'dart run nylo_framework:main make:stateful_widget home_tab,settings_tab'
          /// [Journey States] 'dart run nylo_framework:main make:journey_widget welcome_tab,users_dob,users_info --parent=Base'
          return {
            0: NavigationTab(
              title: "Feed",
              page: Feed(),
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.home),
            ),
            1: NavigationTab(
              title: "Upload",
              page: Upload(),
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
            ),
            2: NavigationTab(
              title: "Saved",
              page: Saved(),
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
            ),
            3: NavigationTab(
              title: "Profile",
              page: Profile(),
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
            ),
          };
        });

  /// Handle the tap event
  @override
  onTap(int index) {
    super.onTap(index);
  }
}

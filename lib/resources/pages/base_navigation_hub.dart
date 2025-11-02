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

  static NavigationHubStateActions stateActions =
      NavigationHubStateActions(path.stateName());
}

class _BaseNavigationHubState extends NavigationHub<BaseNavigationHub> {

  NavigationHubLayout? layout = NavigationHubLayout.bottomNav(

      );

  @override
  bool get maintainState => false;

  _BaseNavigationHubState()
      : super(() async {

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

  @override
  onTap(int index) {
    super.onTap(index);

    if (index != 0) {

      _pauseAllVideosInFeed();
    }
  }

  void _pauseAllVideosInFeed() {

  }
}

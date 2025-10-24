import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class OnlineSafetyActPage extends NyStatefulWidget {

  static RouteView path = ("/online-safety-act", (_) => OnlineSafetyActPage());
  
  OnlineSafetyActPage({super.key}) : super(child: () => _OnlineSafetyActPageState());
}

class _OnlineSafetyActPageState extends NyPage<OnlineSafetyActPage> {

  @override
  get init => () {

  };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online Safety Act")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}

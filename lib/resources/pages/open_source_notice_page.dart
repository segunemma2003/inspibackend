import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class OpenSourceNoticePage extends NyStatefulWidget {

  static RouteView path = ("/open-source-notice", (_) => OpenSourceNoticePage());
  
  OpenSourceNoticePage({super.key}) : super(child: () => _OpenSourceNoticePageState());
}

class _OpenSourceNoticePageState extends NyPage<OpenSourceNoticePage> {

  @override
  get init => () {

  };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Open Source Notice")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}

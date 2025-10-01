import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class TermsPage extends NyStatefulWidget {

  static RouteView path = ("/terms", (_) => TermsPage());
  
  TermsPage({super.key}) : super(child: () => _TermsPageState());
}

class _TermsPageState extends NyPage<TermsPage> {

  @override
  get init => () {

  };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}

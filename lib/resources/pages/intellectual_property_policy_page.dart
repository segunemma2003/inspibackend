import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class IntellectualPropertyPolicyPage extends NyStatefulWidget {

  static RouteView path = ("/intellectual-property-policy", (_) => IntellectualPropertyPolicyPage());
  
  IntellectualPropertyPolicyPage({super.key}) : super(child: () => _IntellectualPropertyPolicyPageState());
}

class _IntellectualPropertyPolicyPageState extends NyPage<IntellectualPropertyPolicyPage> {

  @override
  get init => () {

  };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Intellectual Property Policy")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}

import 'package:nylo_framework/nylo_framework.dart';
import 'bootstrap/boot.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/app/services/firebase_messaging_service.dart';
import '/app/services/auth_service.dart'; // Import auth instance

void main() async {

  await Nylo.init(
    setup: Boot.nylo,
    setupFinished: Boot.finished,

  );
}

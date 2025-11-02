import 'package:nylo_framework/nylo_framework.dart';

/* Keys
|--------------------------------------------------------------------------
| Storage keys are used to read and write to local storage.
| E.g. static StorageKey coins = "SK_COINS";
| String coins = await Keys.coins.read();
|
| Learn more: https://nylo.dev/docs/6.x/storage#storage-keys
|-------------------------------------------------------------------------- */

class Keys {

  static syncedOnBoot() => () async {
        return [
          auth,
          bearerToken,

        ];
      };

  static StorageKey auth = getEnv('SK_USER', defaultValue: 'SK_USER');

  static StorageKey bearerToken = 'SK_BEARER_TOKEN';

}

const String EmailKey = 'email';
const String OtpKey = 'otp';
const String OtpTypeKey = 'type';
const String OtpTypeKey_PasswordReset = 'password_reset';
const String OtpTypeKey_Registration = 'registration';

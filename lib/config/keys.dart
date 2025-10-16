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
  // Define the keys you want to be synced on boot
  static syncedOnBoot() => () async {
        return [
          auth,
          bearerToken,
          // coins.defaultValue(10), // give the user 10 coins by default
        ];
      };

  static StorageKey auth = getEnv('SK_USER', defaultValue: 'SK_USER');

  static StorageKey bearerToken = 'SK_BEARER_TOKEN';

  // static StorageKey coins = 'SK_COINS';

  /// Add your storage keys here...
}

/// App Keys
///
/// Used for passing data between routes and for API calls
///
/// Make sure to document each key

// Example:
// const String kTestKey = 'test_key';

const String EmailKey = 'email';
const String OtpKey = 'otp';
const String OtpTypeKey = 'type';
const String OtpTypeKey_PasswordReset = 'password_reset';
const String OtpTypeKey_Registration = 'registration';

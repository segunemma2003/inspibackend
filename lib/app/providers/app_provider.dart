import '/config/keys.dart';
import '/app/forms/style/form_style.dart';
import '/config/form_casts.dart';
import '/config/decoders.dart';
import '/config/design.dart';
import '/config/theme.dart';
import '/config/validation_rules.dart';
import '/config/localization.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/category.dart';
import '../networking/category_api_service.dart';

class AppProvider implements NyProvider {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      print('📱 AppProvider: Loading categories from API...');

      // Use real API call to fetch categories
      final categories = await api<CategoryApiService>(
        (request) => request.getCategories(),
        cacheKey: "app_categories",
        cacheDuration: const Duration(hours: 1),
      );

      if (categories != null) {
        _categories = categories;
        print(
            '📱 AppProvider: Loaded ${categories.length} categories from API');
      } else {
        print('❌ AppProvider: Failed to load categories from API');
        _categories = [];
      }
    } catch (e) {
      print('❌ AppProvider: Error loading categories: $e');
      _categories = [];
    } finally {
      _isLoading = false;
    }
  }

  @override
  boot(Nylo nylo) async {
    await NyLocalization.instance.init(
      localeType: localeType,
      languageCode: languageCode,
      assetsDirectory: assetsDirectory,
    );

    FormStyle formStyle = FormStyle();

    nylo.addLoader(loader);
    nylo.addLogo(logo);
    nylo.addThemes(appThemes);
    nylo.addToastNotification(getToastNotificationWidget);
    nylo.addValidationRules(validationRules);
    nylo.addModelDecoders(modelDecoders);
    nylo.addControllers(controllers);
    nylo.addApiDecoders(apiDecoders);
    nylo.addFormCasts(formCasts);
    nylo.useErrorStack();
    nylo.addFormStyle(formStyle);
    nylo.addAuthKey(Keys.auth);
    await nylo.syncKeys(Keys.syncedOnBoot);

    // Auth is configured via the global auth instance exported from auth_service.dart

    // Optional
    // nylo.showDateTimeInLogs(); // Show date time in logs
    // nylo.monitorAppUsage(); // Monitor the app usage
    // nylo.broadcastEvents(); // Broadcast events in the app

    return nylo;
  }

  @override
  afterBoot(Nylo nylo) async {}
}

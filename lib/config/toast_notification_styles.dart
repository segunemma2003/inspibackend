import 'package:nylo_framework/nylo_framework.dart';

/* Toast Notification Styles
|--------------------------------------------------------------------------
| Define your toast notification styles here.
|-------------------------------------------------------------------------- */

class NyToastNotificationStyleMetaHelper
    extends ToastNotificationStyleMetaHelper {
  NyToastNotificationStyleMetaHelper(super.style);

  @override
  onSuccess() {
    return ToastMeta.success();
  }

  @override
  onWarning() {
    return ToastMeta.warning();
  }

  @override
  onInfo() {
    return ToastMeta.info();
  }

  @override
  onDanger() {
    return ToastMeta.danger();
  }

}

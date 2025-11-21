# Subscription Upgrade Page - Setup Guide

## Overview

A complete subscription upgrade flow has been implemented that allows users to:
1. **Upgrade to Business Account** (Free)
2. **Upgrade to Professional Plan** (£50/month via Apple Pay)

## Files Created/Modified

### New Files:
- `lib/resources/pages/subscription_upgrade_page.dart` - Main subscription upgrade page

### Modified Files:
- `pubspec.yaml` - Added `in_app_purchase: ^3.1.11` package
- `lib/routes/router.dart` - Added route for subscription upgrade page
- `lib/resources/pages/settings_page.dart` - Added "Upgrade Account" option
- `lib/app/networking/user_api_service.dart` - Added `upgradeToBusiness()` method

## Setup Instructions

### 1. Install Dependencies

Run the following command to install the in-app purchase package:

```bash
flutter pub get
```

### 2. Configure Apple Pay / In-App Purchase

#### iOS Setup:
1. **Add Product ID to App Store Connect**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Navigate to your app → **Features** → **In-App Purchases**
   - Create a new subscription product:
     - **Product ID**: `com.yourapp.professional_monthly` (or update in code)
     - **Type**: Auto-Renewable Subscription
     - **Price**: £50.00 GBP per month
     - **Duration**: 1 month

2. **Update Product ID in Code**:
   - Open `lib/resources/pages/subscription_upgrade_page.dart`
   - Find line: `static const String _professionalProductId = 'com.yourapp.professional_monthly';`
   - Update with your actual product ID

3. **Configure Capabilities**:
   - In Xcode, go to your app target → **Signing & Capabilities**
   - Ensure **In-App Purchase** capability is enabled

### 3. Backend API Endpoints Required

The following endpoints need to be implemented on your backend:

#### Business Account Upgrade:
```
POST /api/users/upgrade-business
Headers: Authorization: Bearer {token}
Response: {
    "success": true,
    "message": "Business account activated successfully",
    "data": {
        "user": {...},
        "is_business": true
    }
}
```

#### Professional Subscription:
- Already documented in `BACKEND_API_REQUIREMENTS.md`
- Endpoint: `POST /api/subscription/upgrade`
- Expects: `{"apple_receipt": "base64_encoded_receipt"}`

## How It Works

### Business Account Upgrade:
1. User taps "Upgrade Now" on Business Account card
2. App calls `POST /api/users/upgrade-business`
3. Backend sets `is_business = true` for user
4. Success message shown, user data reloaded

### Professional Subscription:
1. User taps "Subscribe with Apple Pay" on Professional Plan card
2. App initiates Apple Pay purchase flow via `in_app_purchase` package
3. After successful purchase, Apple provides receipt data
4. App sends receipt to backend: `POST /api/subscription/upgrade`
5. Backend validates receipt with Apple and activates subscription
6. Success message shown, user data reloaded

## UI Features

### Plan Cards:
- **Business Account**: Free, shows business features
- **Professional Plan**: £50/month, shows professional features with "POPULAR" badge
- Cards highlight when selected
- Check mark appears on selected plan

### Current Status Section:
- Shows if user already has Business Account or Professional Plan
- Displays days remaining for Professional subscription
- Only visible if user has active upgrade

### Apple Pay Integration:
- Uses `in_app_purchase` package for iOS
- Handles purchase flow automatically
- Validates receipt with backend
- Shows appropriate error messages

## Navigation

Users can access the upgrade page from:
- **Settings Page**: Tap "Upgrade Account" in Account section
- **Route**: `/dashboard/subscription-upgrade`

## Testing

### Test Business Upgrade:
1. Navigate to Settings → Upgrade Account
2. Tap "Upgrade Now" on Business Account card
3. Verify API call is made to `/api/users/upgrade-business`
4. Check user's `is_business` field is updated

### Test Professional Subscription:
1. Navigate to Settings → Upgrade Account
2. Tap "Subscribe with Apple Pay" on Professional Plan card
3. Use sandbox test account in Apple Pay dialog
4. Verify receipt is sent to backend
5. Check subscription is activated

### Sandbox Testing:
- Use sandbox test accounts from App Store Connect
- Test with sandbox environment before production
- Verify receipt validation works correctly

## Important Notes

1. **Product ID**: Must match exactly with App Store Connect product ID
2. **Receipt Validation**: Backend must validate receipts server-side
3. **Error Handling**: All errors are shown via toast notifications
4. **Loading States**: Shows loading indicators during API calls
5. **Platform Check**: In-app purchases only work on iOS (Apple Pay)

## Troubleshooting

### "In-app purchases are not available"
- Check if running on iOS device or simulator
- Verify In-App Purchase capability is enabled in Xcode
- Ensure device is signed in with Apple ID

### "Failed to activate subscription"
- Check backend receipt validation
- Verify `APPLE_SHARED_SECRET` is configured correctly
- Check product ID matches App Store Connect

### Purchase not completing
- Check network connection
- Verify backend endpoint is accessible
- Check server logs for receipt validation errors

## Next Steps

1. ✅ Run `flutter pub get` to install dependencies
2. ✅ Configure product ID in App Store Connect
3. ✅ Update product ID in code if different
4. ✅ Implement backend endpoint: `POST /api/users/upgrade-business`
5. ✅ Test with sandbox accounts
6. ✅ Deploy to production

## Support

For issues:
- Check backend API logs
- Verify Apple receipt validation
- Review `BACKEND_API_REQUIREMENTS.md` for API specifications
- Test with sandbox environment first


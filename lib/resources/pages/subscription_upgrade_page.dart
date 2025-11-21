import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/app/models/subscription.dart';
import 'package:flutter_app/app/networking/subscription_api_service.dart';
import 'package:flutter_app/app/networking/user_api_service.dart';
import 'package:flutter_app/app/services/subscription_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '/config/app_colors.dart';

class SubscriptionUpgradePage extends NyStatefulWidget {
  static RouteView path =
      ("/subscription-upgrade", (_) => SubscriptionUpgradePage());

  SubscriptionUpgradePage({super.key})
      : super(child: () => _SubscriptionUpgradePageState());
}

class _SubscriptionUpgradePageState extends NyPage<SubscriptionUpgradePage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isAvailable = false;
  bool _isLoading = false;
  bool _isPurchasing = false;
  List<ProductDetails> _products = [];
  List<SubscriptionPlan> _plans = [];
  Map<String, ProductDetails> _productMap = {}; // Maps apple_product_id to ProductDetails
  User? _currentUser;
  SubscriptionPlan? _selectedPlan;
  Map<String, dynamic>? _subscriptionStatus;
  bool _isAlreadySubscribed = false;

  @override
  get init => () async {
        setState(() {
          _isLoading = true;
        });
        await _loadUserData();
        await _checkSubscriptionStatus();
        await _loadSubscriptionPlans();
        // Initialize in-app purchase after plans are loaded so products can be fetched
        await _initializeInAppPurchase();
        setState(() {
          _isLoading = false;
        });
      };

  Future<void> _loadUserData() async {
    try {
      final user = await api<UserApiService>(
        (request) => request.fetchCurrentUser(),
      );
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  /// Load all subscription plans from backend
  Future<void> _loadSubscriptionPlans() async {
    try {
      final response = await api<SubscriptionApiService>(
        (request) => request.getSubscriptionPlans(),
      );

      if (response != null && response['success'] == true && mounted) {
        final List<dynamic> plansData = response['data'] ?? [];
        final List<SubscriptionPlan> plans = plansData
            .map((planData) => SubscriptionPlan.fromJson(planData))
            .where((plan) => plan.isActive == true) // Only show active plans
            .toList();

        // Sort plans: default first, then by name
        plans.sort((a, b) {
          if (a.isDefault == true && b.isDefault != true) return -1;
          if (a.isDefault != true && b.isDefault == true) return 1;
          return (a.name ?? '').compareTo(b.name ?? '');
        });

        setState(() {
          _plans = plans;
        });
        print('📱 Subscription Plans loaded: ${_plans.length} plans');
      }
    } catch (e) {
      print('❌ Error loading subscription plans: $e');
    }
  }

  /// Step 2: Check subscription status before allowing purchase
  Future<void> _checkSubscriptionStatus() async {
    try {
      final response = await api<SubscriptionApiService>(
        (request) => request.getSubscriptionStatus(),
      );

      if (response != null && response['success'] == true && mounted) {
        setState(() {
          _subscriptionStatus = response['data'];
          _isAlreadySubscribed = response['data']?['is_professional'] == true &&
              response['data']?['subscription_status'] == 'active';
        });
        print('📱 Subscription Status: $_subscriptionStatus');

        if (_isAlreadySubscribed) {
          print('⚠️ User already has active subscription');
        }
      }
    } catch (e) {
      print('❌ Error checking subscription status: $e');
    }
  }

  Future<void> _initializeInAppPurchase() async {
    if (!Platform.isIOS) {
      if (mounted) {
        setState(() {
          _isAvailable = false;
        });
      }
      return;
    }

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      if (mounted) {
        setState(() {
          _isAvailable = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isAvailable = true;
      });
    }

    // Load products
    await _loadProducts();

    // Listen to purchase updates
    _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => print('Purchase stream closed'),
      onError: (error) => print('Purchase stream error: $error'),
    );
  }

  Future<void> _loadProducts() async {
    if (_plans.isEmpty) {
      print('⚠️ No plans available to load products');
      return;
    }

    // Get all apple_product_id values from plans
    final Set<String> productIds = _plans
        .where((plan) => plan.appleProductId != null && plan.appleProductId!.isNotEmpty)
        .map((plan) => plan.appleProductId!)
        .toSet();

    if (productIds.isEmpty) {
      print('⚠️ No Apple product IDs found in plans');
      return;
    }

    print('📱 Loading products for IDs: $productIds');
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);

    if (mounted) {
      setState(() {
        _products = response.productDetails;
        // Create a map for easy lookup
        _productMap = {
          for (var product in response.productDetails) product.id: product
        };
      });
      print('📱 Loaded ${_products.length} products from App Store');
    }
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print('📱 Purchase Update:');
      print('   - Status: ${purchaseDetails.status}');
      print('   - Product ID: ${purchaseDetails.productID}');
      print('   - Purchase ID: ${purchaseDetails.purchaseID}');
      print(
          '   - Pending Complete: ${purchaseDetails.pendingCompletePurchase}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI - Apple Pay is processing
        print('📱 Purchase pending - waiting for Apple Pay confirmation');
        setState(() {
          _isPurchasing = true;
        });
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        print('❌ Purchase error: ${purchaseDetails.error}');
        _handleError(purchaseDetails.error!);
        setState(() {
          _isPurchasing = false;
        });
        _inAppPurchase.completePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and process purchase with backend
        print('✅ Purchase successful - verifying with backend...');
        _verifyAndProcessPurchase(purchaseDetails);
      }

      // Complete the purchase to acknowledge receipt
      if (purchaseDetails.pendingCompletePurchase) {
        print('📱 Completing purchase...');
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyAndProcessPurchase(
      PurchaseDetails purchaseDetails) async {
    try {
      setState(() {
        _isPurchasing = true;
      });

      // Get receipt data - use serverVerificationData for receipt validation
      // This contains the base64-encoded receipt that Apple provides
      final receiptData =
          purchaseDetails.verificationData.serverVerificationData;

      print('📱 Purchase Details:');
      print('   - Product ID: ${purchaseDetails.productID}');
      print('   - Transaction ID: ${purchaseDetails.purchaseID}');
      print('   - Status: ${purchaseDetails.status}');
      print('   - Receipt Data Length: ${receiptData.length}');

      if (_selectedPlan != null) {
        // Upgrade to selected plan with Apple Pay receipt
        print('📱 Sending receipt to backend for validation...');
        print('📱 Selected Plan: ${_selectedPlan!.name} (${_selectedPlan!.appleProductId})');

        final response = await api<SubscriptionApiService>(
          (request) => request.upgradeToProfessional(appleReceipt: receiptData),
        );

        print('📱 Backend Response: $response');

        if (response != null && response['success'] == true) {
          showToast(
            title: "Success",
            description: response['message'] ??
                "${_selectedPlan!.name} subscription activated successfully!",
            style: ToastNotificationStyleType.success,
          );

          // Reload user data and subscription status
          await _loadUserData();
          await _checkSubscriptionStatus();

          // Navigate back
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Handle specific error cases from backend
          final message = response?['message'] ??
              "Failed to activate subscription. Please try again.";
          final errorCode = response?['error_code'];

          String errorMessage = message;
          if (errorCode != null) {
            switch (errorCode) {
              case 21003:
                errorMessage =
                    "Invalid receipt. Please try again or contact support.";
                break;
              case 21007:
                errorMessage = "Receipt validation error. Please try again.";
                break;
            }
          }

          // Check if already subscribed
          if (message.toLowerCase().contains('already have an active')) {
            await _checkSubscriptionStatus();
            showToast(
              title: "Already Subscribed",
              description: message,
              style: ToastNotificationStyleType.warning,
            );
          } else {
            showToast(
              title: "Error",
              description: errorMessage,
              style: ToastNotificationStyleType.danger,
            );
          }
        }
      }

      setState(() {
        _isPurchasing = false;
      });
    } catch (e) {
      print('❌ Error verifying purchase: $e');
      setState(() {
        _isPurchasing = false;
      });
      showToast(
        title: "Error",
        description: "Failed to process purchase: $e",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  void _handleError(IAPError error) {
    print('❌ Purchase error: ${error.message}');
    showToast(
      title: "Purchase Error",
      description: error.message,
      style: ToastNotificationStyleType.danger,
    );
  }

  Future<void> _purchasePlan(SubscriptionPlan plan) async {
    if (!_isAvailable || _products.isEmpty) {
      showToast(
        title: "Error",
        description:
            "In-app purchases are not available. Please check your App Store settings.",
        style: ToastNotificationStyleType.danger,
      );
      return;
    }

    if (plan.appleProductId == null || plan.appleProductId!.isEmpty) {
      showToast(
        title: "Error",
        description: "This plan is not configured for in-app purchases.",
        style: ToastNotificationStyleType.danger,
      );
      return;
    }

    final product = _productMap[plan.appleProductId];
    if (product == null) {
      showToast(
        title: "Error",
        description: "Product not found in App Store. Please contact support.",
        style: ToastNotificationStyleType.danger,
      );
      print('❌ Product not found for ID: ${plan.appleProductId}');
      return;
    }

    print('📱 Initiating purchase for plan: ${plan.name}');
    print('📱 Product ID: ${product.id}');
    print('📱 Product Price: ${product.price}');
    print('📱 Product Title: ${product.title}');

    // Set selected plan before purchase
    setState(() {
      _selectedPlan = plan;
    });

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    // For auto-renewable subscriptions on iOS, use buyNonConsumable
    // This will trigger the Apple Pay payment flow
    final bool success = await _inAppPurchase.buyNonConsumable(
      purchaseParam: purchaseParam,
    );

    if (!success) {
      showToast(
        title: "Error",
        description: "Failed to initiate purchase. Please try again.",
        style: ToastNotificationStyleType.danger,
      );
      setState(() {
        _selectedPlan = null;
      });
    } else {
      // Purchase flow initiated - Apple Pay dialog will appear
      // The purchase will be handled in _handlePurchaseUpdate
      setState(() {
        _isPurchasing = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Upgrade Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading || _isPurchasing
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  SizedBox(height: 40),

                  // Display all subscription plans
                  if (_plans.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No subscription plans available at the moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ..._plans.asMap().entries.map((entry) {
                      final index = entry.key;
                      final plan = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < _plans.length - 1 ? 20 : 0),
                        child: _buildPlanCard(plan: plan),
                      );
                    }),

                  SizedBox(height: 40),

                  // Current Status
                  if (_currentUser != null) _buildCurrentStatus(),

                  SizedBox(height: 20),

                  // Terms and Conditions
                  _buildTermsAndConditions(),

                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.star,
            color: Colors.white,
            size: 40,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Upgrade Your Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Choose the plan that\'s right for you',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanCard({required SubscriptionPlan plan}) {
    final isSelected = _selectedPlan?.id == plan.id;
    final isDisabled = _isAlreadySubscribed;
    final product = plan.appleProductId != null
        ? _productMap[plan.appleProductId]
        : null;
    
    // Get price from App Store product if available, otherwise use plan price
    String priceText = '';
    if (product != null) {
      priceText = product.price;
    } else if (plan.price != null) {
      final currencySymbol = plan.currency == 'GBP' ? '£' : 
                             plan.currency == 'USD' ? '\$' : 
                             plan.currency == 'EUR' ? '€' : '';
      priceText = '$currencySymbol${plan.price!.toStringAsFixed(2)}';
    } else {
      priceText = 'Price not available';
    }

    // Get features
    final features = plan.features ?? [];

    // Determine color based on plan
    Color planColor = plan.isDefault == true 
        ? AppColors.primaryPink 
        : AppColors.primaryBlue;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              if (_isAvailable && product != null) {
                _purchasePlan(plan);
              } else if (product == null) {
                showToast(
                  title: "Error",
                  description: "This plan is not available for purchase.",
                  style: ToastNotificationStyleType.danger,
                );
              } else {
                showToast(
                  title: "Error",
                  description: "In-app purchases not available",
                  style: ToastNotificationStyleType.danger,
                );
              }
            },
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? planColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? planColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: planColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          color: planColor,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.name ?? 'Subscription Plan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (plan.isDefault == true) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'POPULAR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${plan.durationDays ?? 30} days subscription',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: planColor,
                      size: 28,
                    ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                priceText,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: planColor,
                ),
              ),
              Text(
                ' per ${plan.durationDays ?? 30} days',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 16),
              if (features.isEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'No features listed',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              else
                ...features.map((feature) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: planColor,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [planColor, planColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: isDisabled
                        ? () {
                            showToast(
                              title: "Already Subscribed",
                              description:
                                  "You already have an active subscription",
                              style: ToastNotificationStyleType.warning,
                            );
                          }
                        : () {
                            if (_isAvailable && product != null) {
                              _purchasePlan(plan);
                            } else if (product == null) {
                              showToast(
                                title: "Error",
                                description: "This plan is not available for purchase.",
                                style: ToastNotificationStyleType.danger,
                              );
                            } else {
                              showToast(
                                title: "Error",
                                description: "In-app purchases not available",
                                style: ToastNotificationStyleType.danger,
                              );
                            }
                          },
                    child: Center(
                      child: Text(
                        'Subscribe with Apple Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatus() {
    final isBusiness = _currentUser?.isBusiness ?? false;
    final isProfessional = SubscriptionService.isProfessional(_currentUser);

    if (!isBusiness && !isProfessional) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (isBusiness)
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: AppColors.primaryBlue, size: 16),
                SizedBox(width: 8),
                Text(
                  'Business Account',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          if (isProfessional) ...[
            if (isBusiness) SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: AppColors.primaryPink, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Professional Plan - ${SubscriptionService.getDaysRemaining(_currentUser) ?? 0} days remaining',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      children: [
        Text(
          'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscriptions will automatically renew unless cancelled.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => routeTo('/terms-of-service'),
              child: Text(
                'Terms of Service',
                style: TextStyle(fontSize: 12, color: AppColors.primaryBlue),
              ),
            ),
            Text(' • ', style: TextStyle(color: Colors.grey[600])),
            TextButton(
              onPressed: () => routeTo('/privacy-policy'),
              child: Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 12, color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

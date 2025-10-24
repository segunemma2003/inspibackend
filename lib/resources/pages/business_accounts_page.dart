import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/app_colors.dart';
import '/app/networking/user_api_service.dart';

class BusinessAccountsPage extends StatefulWidget {
  static RouteView path = ("/business-accounts", (_) => BusinessAccountsPage());
  const BusinessAccountsPage({super.key});

  @override
  createState() => _BusinessAccountsPageState();
}

class _BusinessAccountsPageState extends NyState<BusinessAccountsPage> {
  List<Map<String, dynamic>> _businessAccounts = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  String _searchQuery = '';
  String _selectedType = 'all';

  final TextEditingController _searchController = TextEditingController();

  @override
  get init => () async {
        await _loadBusinessAccounts(1);
      };

  Future<void> _loadBusinessAccounts(int page,
      {bool forceRefresh = false}) async {
    if (!_hasMore && page > 1) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await api<UserApiService>(
        (request) => request.get(
          "/business-accounts",
          queryParameters: {
            'per_page': '20',
            'page': page.toString(),
            if (_searchQuery.isNotEmpty) 'search': _searchQuery,
            if (_selectedType != 'all') 'type': _selectedType,
          },
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> accountsData = response['data']['data'] ?? [];
        final List<Map<String, dynamic>> newAccounts =
            List<Map<String, dynamic>>.from(accountsData);

        setState(() {
          if (page == 1) {
            _businessAccounts = newAccounts;
          } else {
            _businessAccounts.addAll(newAccounts);
          }
          _currentPage = response['data']['current_page'] ?? page;
          _hasMore = _currentPage < (response['data']['last_page'] ?? 1);
        });
      }
    } catch (e) {
      print("Error loading business accounts: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadBusinessAccounts(1, forceRefresh: true);
  }

  void _filterByType(String type) {
    setState(() {
      _selectedType = type;
    });
    _loadBusinessAccounts(1, forceRefresh: true);
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Business Accounts',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading && _businessAccounts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _businessAccounts.isEmpty
                    ? _buildEmptyState()
                    : _buildBusinessAccountsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search business accounts...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: _performSearch,
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Makeup Artist', 'makeup_artist'),
                const SizedBox(width: 8),
                _buildFilterChip('Fashion Designer', 'fashion_designer'),
                const SizedBox(width: 8),
                _buildFilterChip('Photographer', 'photographer'),
                const SizedBox(width: 8),
                _buildFilterChip('Beauty Blogger', 'beauty_blogger'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => _filterByType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPink
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryPink : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessAccountsList() {
    return RefreshIndicator(
      onRefresh: () => _loadBusinessAccounts(1, forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _businessAccounts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _businessAccounts.length) {
            if (_hasMore) {
              _loadBusinessAccounts(_currentPage + 1);
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final account = _businessAccounts[index];
          return _buildBusinessAccountCard(account);
        },
      ),
    );
  }

  Widget _buildBusinessAccountCard(Map<String, dynamic> account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBusinessAvatar(account),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account['business_name'] ?? 'Unknown Business',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      account['business_type'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (account['is_verified'] == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              _buildRatingWidget(account),
            ],
          ),
          const SizedBox(height: 12),
          if (account['business_description'] != null) ...[
            Text(
              account['business_description'],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          _buildBusinessInfo(account),
          const SizedBox(height: 12),
          _buildBusinessActions(account),
        ],
      ),
    );
  }

  Widget _buildBusinessAvatar(Map<String, dynamic> account) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.profileGradient,
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundPrimary,
        ),
        child: ClipOval(
          child: account['user']?['profile_picture'] != null
              ? Image.network(
                  account['user']['profile_picture'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.backgroundTertiary,
                      child: const Icon(Icons.business,
                          size: 30, color: AppColors.textTertiary),
                    );
                  },
                )
              : Container(
                  color: AppColors.backgroundTertiary,
                  child: const Icon(Icons.business,
                      size: 30, color: AppColors.textTertiary),
                ),
        ),
      ),
    );
  }

  Widget _buildRatingWidget(Map<String, dynamic> account) {
    final rating = account['rating']?.toDouble() ?? 0.0;
    final reviewsCount = account['reviews_count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(Icons.star, size: 16, color: AppColors.primaryGold),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          '$reviewsCount reviews',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfo(Map<String, dynamic> account) {
    return Column(
      children: [
        if (account['address'] != null) ...[
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  account['address'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (account['website'] != null) ...[
          Row(
            children: [
              Icon(Icons.language, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  account['website'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryBlue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (account['phone'] != null) ...[
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                account['phone'],
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBusinessActions(Map<String, dynamic> account) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Navigate to business profile
              showToast(
                  title: "Business",
                  description: "Viewing ${account['business_name']}");
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryPink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (account['accepts_bookings'] == true)
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Handle booking
                showToast(
                    title: "Booking",
                    description: "Booking ${account['business_name']}");
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center,
                size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text(
              'No Business Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No business accounts found matching your search.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

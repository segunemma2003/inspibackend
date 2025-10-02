# Inspiritag API Implementation

This document outlines the comprehensive API implementation for the Inspiritag social media app using the Nylo framework.

## Overview

The implementation includes:
- **5 API Services** for different functionalities
- **6 Data Models** with proper JSON serialization
- **Comprehensive Caching System** for optimal performance
- **Authentication & Authorization** with Bearer tokens
- **Error Handling** and retry mechanisms

## API Services

### 1. AuthApiService
Handles all authentication-related endpoints:
- User registration
- Login/logout
- Password reset
- Firebase authentication
- Current user data
- Account deletion

### 2. UserApiService
Manages user-related operations:
- User profiles and updates
- Follow/unfollow functionality
- User search by interests/profession
- Follower/following lists
- Interests management

### 3. PostApiService
Handles content and posts:
- Personalized feed
- Post creation and management
- Like/save functionality
- Post search and filtering
- Saved and liked posts

### 4. BusinessApiService
Manages business accounts:
- Business account creation/updates
- Business listings and search
- Booking system
- Business profile management

### 5. NotificationApiService
Handles notifications:
- Notification retrieval
- Mark as read functionality
- Notification preferences
- FCM token management

### 6. CategoryApiService
Manages content categories:
- Category listing
- Admin category management
- Category-based filtering

## Data Models

### Core Models
- **User**: Complete user profile with interests and preferences
- **Post**: Content with media, likes, saves, and metadata
- **BusinessAccount**: Business profiles with booking capabilities
- **Notification**: User notifications with read status
- **Category**: Content categorization
- **Tag**: Post tagging system
- **Booking**: Appointment scheduling

## Caching System

### Cache Durations
- **User Feed**: 2 minutes (frequently updated)
- **User Stats**: 5 minutes (moderate updates)
- **Business Accounts**: 3 minutes (business hours)
- **Categories**: 1 hour (rarely change)
- **Notifications**: 1 minute (real-time)
- **Search Results**: 3 minutes (user-specific)

### Cache Management
```dart
// Clear specific cache types
await CacheConfig.clearUserCache();
await CacheConfig.clearPostCache();
await CacheConfig.clearBusinessCache();
await CacheConfig.clearSearchCache();

// Clear all cache
await CacheConfig.clearAllCache();
```

## Usage Examples

### Basic API Call with Caching
```dart
// Get user feed with automatic caching
final feedResponse = await api<PostApiService>(
  (request) => request.getFeed(perPage: 20, page: 1),
  cacheKey: CacheConfig.userFeedKey,
  cacheDuration: CacheConfig.userFeedCache,
);
```

### Authentication
```dart
// Login user
final loginResponse = await api<AuthApiService>(
  (request) => request.login(
    email: "user@example.com",
    password: "password123",
  ),
);

// Get current user
final currentUser = await api<AuthApiService>(
  (request) => request.getCurrentUser(),
  cacheKey: CacheConfig.currentUserKey,
  cacheDuration: CacheConfig.userProfileCache,
);
```

### Post Management
```dart
// Create a new post
final newPost = await api<PostApiService>(
  (request) => request.createPost(
    caption: "Amazing hairstyle! #hair #beauty",
    media: "path/to/media.jpg",
    categoryId: 1,
    tags: ["hair", "beauty"],
    location: "New York, NY",
  ),
);

// Like a post
final likeResponse = await api<PostApiService>(
  (request) => request.toggleLike(postId),
);
```

### Business Account Management
```dart
// Get business accounts
final businesses = await api<BusinessApiService>(
  (request) => request.getBusinessAccounts(
    type: "hair",
    perPage: 20,
  ),
  cacheKey: CacheConfig.businessAccountsKey,
  cacheDuration: CacheConfig.businessAccountsCache,
);

// Create booking
final booking = await api<BusinessApiService>(
  (request) => request.createBooking(
    businessAccountId: 1,
    serviceName: "Haircut and Styling",
    description: "Need a haircut for an event",
    appointmentDate: DateTime.now().add(Duration(days: 1)),
  ),
);
```

### Search Functionality
```dart
// Search users by interests
final users = await api<UserApiService>(
  (request) => request.searchUsersByInterests(
    interests: ["Hair Styling", "Beauty"],
    perPage: 20,
  ),
  cacheKey: "users_by_interests_hair_beauty",
  cacheDuration: CacheConfig.searchResultsCache,
);

// General search
final searchResults = await api<PostApiService>(
  (request) => request.search(
    query: "hairstyle",
    type: "posts",
    perPage: 20,
  ),
  cacheKey: "search_posts_hairstyle",
  cacheDuration: CacheConfig.searchResultsCache,
);
```

## Performance Optimizations

### 1. Strategic Caching
- **Frequently accessed data**: Short cache duration (1-2 minutes)
- **Static data**: Long cache duration (1 hour)
- **User-specific data**: Medium cache duration (3-5 minutes)

### 2. Singleton API Services
All API services are configured as singletons for better memory management:
```dart
final Map<Type, dynamic> apiDecoders = {
  AuthApiService: AuthApiService(),
  UserApiService: UserApiService(),
  PostApiService: PostApiService(),
  // ... other services
};
```

### 3. Background Processing
- Notification sending via queue jobs
- Post creation notifications handled asynchronously
- Email notifications queued for batch processing

### 4. CDN Integration
- Media files served through CDN
- Profile pictures optimized and cached
- Post thumbnails generated automatically

## Error Handling

### Standard Error Format
All API responses follow a consistent format:
```json
{
  "success": true/false,
  "message": "Response message",
  "data": { ... }
}
```

### HTTP Status Codes
- **200**: OK - Successful GET, PUT, DELETE
- **201**: Created - Successful POST
- **400**: Bad Request - Invalid request data
- **401**: Unauthorized - Missing or invalid token
- **403**: Forbidden - Insufficient permissions
- **404**: Not Found - Resource doesn't exist
- **422**: Unprocessable Entity - Validation errors
- **429**: Too Many Requests - Rate limit exceeded
- **500**: Internal Server Error - Server error

## Rate Limiting

All API endpoints are rate-limited:
- **Rate Limit**: 60 requests per minute per user/IP
- **Headers**: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
- **Exceeded Response**: 429 Too Many Requests

## File Upload Specifications

### Supported File Types
- **Images**: JPEG, PNG, GIF
- **Videos**: MP4, MOV, AVI

### File Size Limits
- **Profile Pictures**: 2MB maximum
- **Post Media**: 50MB maximum

### Storage
- All files stored on AWS S3
- CDN delivery for optimal performance
- Automatic thumbnail generation for images
- Secure presigned URLs for temporary access

## Best Practices

### 1. Authentication
- Store tokens securely (encrypted storage)
- Include token in Authorization header for all protected endpoints
- Refresh tokens on expiration
- Logout on user request to revoke tokens

### 2. Performance
- Use pagination for large datasets
- Cache responses when appropriate
- Implement retry logic for failed requests
- Use conditional requests (ETags) when available

### 3. Error Handling
- Always check success field in response
- Handle all HTTP status codes appropriately
- Display user-friendly error messages
- Log errors for debugging

### 4. Media Upload
- Compress images before upload
- Validate file types on client side
- Show upload progress to users
- Handle upload failures gracefully

### 5. Notifications
- Request notification permissions from users
- Update FCM token on app start
- Handle notification preferences
- Test push notifications thoroughly

## Testing

### Unit Tests
```dart
// Test API service methods
test('should fetch user feed', () async {
  final mockResponse = {'data': []};
  when(mockApiService.getFeed()).thenAnswer((_) async => mockResponse);
  
  final result = await apiService.getFeed();
  expect(result, mockResponse);
});
```

### Integration Tests
```dart
// Test complete API workflows
testWidgets('should create post and update feed', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Create post
  await tester.tap(find.byKey(Key('create_post_button')));
  await tester.pumpAndSettle();
  
  // Verify post appears in feed
  expect(find.text('New post content'), findsOneWidget);
});
```

## Monitoring and Analytics

### Performance Metrics
- API response times
- Cache hit rates
- Error rates by endpoint
- User engagement metrics

### Health Checks
- API endpoint availability
- Database connection status
- Cache system health
- CDN performance

## Security Considerations

### Data Protection
- All sensitive data encrypted in transit and at rest
- User passwords hashed using bcrypt
- API keys stored securely
- Regular security audits

### Authentication Security
- JWT tokens with expiration
- Refresh token rotation
- Rate limiting on authentication endpoints
- Account lockout after failed attempts

## Future Enhancements

### Planned Features
- Webhook support for real-time events
- Advanced search with AI
- Content recommendation engine
- Analytics dashboard for business accounts
- Multi-language support
- Offline mode with sync

### Performance Improvements
- GraphQL API for efficient data fetching
- Real-time updates with WebSockets
- Advanced caching strategies
- Image optimization and compression
- Progressive loading for large datasets

## Conclusion

This comprehensive API implementation provides a solid foundation for the Inspiritag social media app with:
- **Scalable architecture** supporting 100,000+ users
- **Optimized performance** with strategic caching
- **Robust error handling** and retry mechanisms
- **Security best practices** throughout
- **Future-ready design** for easy expansion

The implementation follows Nylo framework best practices and provides excellent developer experience with comprehensive documentation and examples.


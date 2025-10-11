class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic error;
  
  ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.error,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }
  
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'message': message,
      if (data != null) 'data': toJsonT(data as T),
      if (error != null) 'error': error,
    };
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  
  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
  });
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List).map((item) => fromJsonT(item)).toList(),
      currentPage: json['current_page'] ?? 1,
      totalPages: json['last_page'] ?? 1,
      totalItems: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
    );
  }
}

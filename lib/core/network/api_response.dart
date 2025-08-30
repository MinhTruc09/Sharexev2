/// 🌐 Generic API Response Wrapper
///
/// Dùng chung cho tất cả API response.
/// Hỗ trợ generic <T> cho single object hoặc List<T>.
class ApiResponse<T> {
  final String message;
  final int statusCode;
  final T? data;
  final bool success;

  ApiResponse({
    required this.message,
    required this.statusCode,
    required this.data,
    required this.success,
  });

  /// 🏗️ Parse JSON → ApiResponse<T>
  ///
  /// Dùng khi API trả về **1 object** trong `data`
  ///
  /// Ví dụ:
  /// ```dart
  /// final res = ApiResponse<UserDTO>.fromJson(
  ///   json,
  ///   (data) => UserDTO.fromJson(data),
  /// );
  /// ```
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return ApiResponse<T>(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data:
          json['data'] != null
              ? fromJsonT(json['data'] as Map<String, dynamic>)
              : null,
      success: json['success'] ?? false,
    );
  }

  /// 🏗️ Parse JSON → ApiResponse<List<T>>
  ///
  /// Dùng khi API trả về **list object** trong `data`
  ///
  /// Ví dụ:
  /// ```dart
  /// final res = ApiResponse.listFromJson<UserDTO>(
  ///   json,
  ///   (e) => UserDTO.fromJson(e),
  /// );
  /// print(res.data?.length);
  /// ```
  static ApiResponse<List<T>> listFromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final dataList =
        (json['data'] as List<dynamic>? ?? [])
            .map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList();

    return ApiResponse<List<T>>(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: dataList,
      success: json['success'] ?? false,
    );
  }

  /// 🔄 Convert object ApiResponse<T> → JSON
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      "message": message,
      "statusCode": statusCode,
      "data": data != null ? toJsonT(data as T) : null,
      "success": success,
    };
  }

  /// 🧩 Parse JSON → ApiResponse<T> for primitive types (int, String, bool)
  static ApiResponse<T> primitiveFromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic value) fromValue,
  ) {
    final raw = json['data'];
    return ApiResponse<T>(
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      data: raw != null ? fromValue(raw) : null,
      success: json['success'] ?? false,
    );
  }
}

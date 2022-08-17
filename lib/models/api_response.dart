class ApiResponse {
  final String className;
  final double confidence;

  ApiResponse.fromJson(Map<String, dynamic> data)
      : className = data['class'],
        confidence = data['confidence'];
}

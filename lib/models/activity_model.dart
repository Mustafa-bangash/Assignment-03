class ActivityModel {
  final String id;
  final double latitude;
  final double longitude;
  final String imagePath; // Will store Base64 string or local path
  final String timestamp;

  ActivityModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.timestamp,
  });

  // Convert to Map for API/Storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'timestamp': timestamp,
    };
  }

  // Create from Map
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'].toString(),
      latitude: json['latitude'],
      longitude: json['longitude'],
      imagePath: json['imagePath'],
      timestamp: json['timestamp'],
    );
  }
}
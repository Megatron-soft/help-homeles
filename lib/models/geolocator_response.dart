class GeolocatorResponse {
  final double lat;
  final double long; 
  final bool isSuccess;
  final String message;

  GeolocatorResponse({
    required this.lat,
    required this.isSuccess,
    required this.long,
    required this.message
  });

}
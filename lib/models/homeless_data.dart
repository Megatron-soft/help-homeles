import 'package:shelter/models/needs.dart';

class CardData {
  final String? imageUrl;
  final List<Need> needs;
  String? city;
  double lat;
  double long;

  CardData({
    this.imageUrl,
    this.city,
    required this.needs,
    required this.lat,
    required this.long,
  });

  // Convert from JSON to CardData
  factory CardData.fromJson(Map<String, dynamic> json) {
    // Split the description by comma and convert each part to a Need object
    var needsList = (json['description'] as String)
        .split(',')
        .map((item) => Need(need: item.trim(), isActive: true))
        .toList();

    return CardData(
      imageUrl: json['image_url'],
      city: json['city'],
      needs: needsList,
      lat: json['lat'],
      long: json['long'],
    );
  }

  // Convert CardData to JSON
  Map<String, dynamic> toJson() {
    // Convert the list of Need objects back to a comma-separated string
    String description = needs.map((need) => need.need).join(', ');

    return {
      'image_url': imageUrl,
      'description': description,
      'city': city,
      'lat': lat,
      'long': long,
    };
  }
}

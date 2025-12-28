class LocationResponse {
  final int id;
  final String name;
  final String description;
  final String thumbnail;
  final String websiteUrl;
  final int hotelId;

  const LocationResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
    required this.websiteUrl,
    required this.hotelId,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      websiteUrl: json['websiteUrl']?.toString() ?? '',
      hotelId: (json['hotelId'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnail': thumbnail,
      'websiteUrl': websiteUrl,
      'hotelId': hotelId,
    };
  }

  bool get hasWebsite => websiteUrl.trim().isNotEmpty;
  bool get hasThumbnail => thumbnail.trim().isNotEmpty;
}



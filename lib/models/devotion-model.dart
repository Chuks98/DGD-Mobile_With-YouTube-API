class Devotion {
  final String? id;
  final String topic;
  final String description;
  final String youtubeLink;
  final int? reviews;
  final String? selectedDate;
  final String? thumbnail;

  Devotion({
    this.id,
    required this.topic,
    required this.description,
    required this.youtubeLink,
    this.reviews,
    this.selectedDate,
    this.thumbnail,
  });

  // Convert Devotion object to a JSON map (for sending data)
  Map<String, dynamic> toJson() => {
        "_id": id,
        'topic': topic,
        'description': description,
        'youtubeLink': youtubeLink,
        'reviews': reviews,
        'selectedDate': selectedDate, // No conversion needed
        'thumbnail': thumbnail,
      };

  // Create a Devotion object from a JSON map (for receiving data)
  factory Devotion.fromJson(Map<String, dynamic> json) => Devotion(
        id: json['_id'] as String,
        topic: json['topic'] as String,
        description: json['description'] as String,
        youtubeLink: json['youtubeLink'] as String,
        reviews: json['reviews'] as int?,
        selectedDate: json['selectedDate'] as String,
        thumbnail: json['thumbnail'] as String?,
      );
}

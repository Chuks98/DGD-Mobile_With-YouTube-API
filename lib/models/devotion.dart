class Devotion {
  int id;
  String topic;
  String thumbnail;
  String description;
  int? reviews;
  DateTime modifiedTime;

  Devotion({
    required this.id,
    required this.topic,
    required this.thumbnail,
    required this.description,
    this.reviews,
    required this.modifiedTime,
  });
}


List<Devotion> sampleNotes = [
  Devotion(
    id: 0,
    topic: 'Like and Subscribe',
    thumbnail: "assets/thumbnails/2.jpg",
    description: 'A FREE way to support the channel is to give us a LIKE . It does not cost you but means a lot to us.\nIf you are new here please Subscribe',
    reviews: 4,
    modifiedTime: DateTime(2022,1,1,34,5),
  ),
  Devotion(
    id: 1,
    topic: 'Recipes to Try',
    thumbnail: "assets/thumbnails/3.jpg",
    description: '1. Chicken Alfredo\n2. Vegan chili\n3. Spaghetti carbonara\n4. Chocolate lava cake',
    reviews: 4,
    modifiedTime: DateTime(2022,1,1,34,5),
  ),
  Devotion(
    id: 2,
    topic: 'Books to Read',
    thumbnail: "assets/thumbnails/bsc.PNG",
    description: '1. To Kill a Mockingbird\n2. 1984\n3. The Great Gatsby\n4. The Catcher in the Rye',
    reviews: 4,
    modifiedTime: DateTime(2023,3,1,19,5),
  ),
  Devotion(
    id: 3,
    topic: 'Gift Ideas for Mom',
    thumbnail: "assets/thumbnails/2.jpg",
    description: '1. Jewelry box\n2. Cookbook\n3. Scarf\n4. Spa day gift card',
    reviews: 5,
    modifiedTime: DateTime(2023,1,4,16,53),
  ),
  Devotion(
    id: 4,
    topic: 'Workout Plan',
    thumbnail: "assets/thumbnails/2.jpg",
    description: 'Monday:\n- Run 5 miles\n- Yoga class\nTuesday:\n- HIIT circuit training\n- Swimming laps\nWednesday:\n- Rest day\nThursday:\n- Weightlifting\n- Spin class\nFriday:\n- Run 3 miles\n- Pilates class\nSaturday:\n- Hiking\n- Rock climbing',
    reviews: 3,
    modifiedTime: DateTime(2023,5,1,11,6),
  ),
  Devotion(
    id: 5,
    topic: 'Bucket List',
    thumbnail: "assets/thumbnails/2.jpg",
    description: '1. Travel to Japan\n2. Learn to play the guitar\n3. Write a novel\n4. Run a marathon\n5. Start a business',
    reviews: 2,
    modifiedTime: DateTime(2023,1,6,13,9),
  ),
  Devotion(
    id: 6,
    topic: 'Little pigs',
    thumbnail: "assets/thumbnails/2.jpg",
    description: "Once upon a time there were three little pigs who set out to seek their fortune.",
    reviews: 4,
    modifiedTime: DateTime(2023,3,7,11,12),
  ),
  Devotion(
    id: 7,
    topic: 'Meeting Notes',
    thumbnail: "assets/thumbnails/2.jpg",
    description: 'Attendees: John, Mary, David\nAgenda:\n- Budget review\n- Project updates\n- Upcoming events',
    reviews: 1,
    modifiedTime: DateTime(2023,2,1,15,14),
  ),
];

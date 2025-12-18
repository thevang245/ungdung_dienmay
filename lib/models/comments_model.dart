class Comment {
  final int id;
  final String name;
  final String avatar;
  final String content;
  final DateTime time;
  final int rating;

  Comment({
    required this.id,
    required this.name,
    required this.avatar,
    required this.content,
    required this.time,
    required this.rating,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      name: json['nguoidang'],
      avatar: json['hinhdaidien'],
      content: json['noidungbinhluan'],
      time: DateTime.parse(json['ngaydang']),
      rating: (json['rating'] / 50).round(),
    );
  }
}
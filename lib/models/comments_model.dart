class Comment {
  final int id;
  final String name;
  final String avatar;
  final String content;
  final DateTime time;
  final int rating;
  final List<Comment> replies;

  Comment(
      {required this.id,
      required this.name,
      required this.avatar,
      required this.content,
      required this.time,
      required this.rating,
      required this.replies});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        id: json['id'],
        name: json['nguoidang'],
        avatar: json['hinhdaidien'],
        content: json['noidungbinhluan'] ?? json['noidung'] ?? '',
        time: DateTime.parse(json['ngaydang']),
        rating: (json['rating'] / 50).round(),
        replies: json['replies'] != null
            ? (json['replies'] as List).map((e) => Comment.fromJson(e)).toList()
            : []);
  }
}

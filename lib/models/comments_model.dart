class Comment {
  final int id;
  final String name;
  final String avatar;
  final String content;
  final DateTime time;
bool isLiking = false;

  final int rating;        
  int likeCount;           
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.name,
    required this.avatar,
    required this.content,
    required this.time,
    required this.rating,
    required this.likeCount,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      name: json['nguoidang'] ?? '',
      avatar: json['hinhdaidien'] ?? '',
      content: json['noidungbinhluan'] ?? json['noidung'] ?? '',
      time: DateTime.tryParse(json['ngaydang'] ?? '') ?? DateTime.now(),

      // ⭐ rating chỉ có ở comment cha
      rating: ((json['rating'] ?? 0) / 50).round(),

      // ❤️ số lượt thích
      likeCount: json['soluongthich'] ?? 0,

      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => Comment.fromJson(e))
              .toList()
          : [],
    );
  }
}

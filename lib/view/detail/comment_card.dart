import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comments_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CommentListWidget extends StatefulWidget {
  final int postId;

  const CommentListWidget({super.key, required this.postId});

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  late Future<List<Comment>> futureComments;

  @override
  void initState() {
    super.initState();
    futureComments = loadComments();
  }

  Future<List<Comment>> loadComments() async {
    try {
      final comments = await APIService.fetchComments(widget.postId);
      return comments;
    } catch (e) {
      print('Error loading comments: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<Comment>>(
            future: futureComments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Chưa có bình luận nào'));
              } else {
                final comments = snapshot.data!;
                return Column(
                  children: comments.map((c) {
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  'https://vangtran.125.atoz.vn${c.avatar}'),
                              radius: 25,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        '${c.time.day}/${c.time.month}/${c.time.year} ${c.time.hour}:${c.time.minute}',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  RatingBarIndicator(
                                    rating: c.rating.toDouble(),
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(c.content),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets
                                          .only(top: 5), 
                                      minimumSize: Size(
                                          0, 0),
                                      tapTargetSize: MaterialTapTargetSize
                                          .shrinkWrap, 
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'Trả lời',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

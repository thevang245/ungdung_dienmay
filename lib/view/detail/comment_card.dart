import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comments_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/detail/comment_form.dart';
import 'package:flutter_application_1/widgets/build_comments.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CommentListWidget extends StatefulWidget {
  final int postId;
  final Function(int?) onReply;
  final int? replyToCommentId;

  const CommentListWidget(
      {super.key,
      required this.postId,
      required this.onReply,
      required this.replyToCommentId});

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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FutureBuilder<List<Comment>>(
        future: futureComments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có bình luận nào'));
          }

          final comments = snapshot.data!;

          return Column(
            children: comments.map((c) {
              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              'https://vangtran.125.atoz.vn${c.avatar}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${c.time.day}/${c.time.month}/${c.time.year} '
                                      '${c.time.hour}:${c.time.minute}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                RatingBarIndicator(
                                  rating: c.rating.toDouble(),
                                  itemBuilder: (_, __) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 18,
                                ),
                                const SizedBox(height: 4),
                                Text(c.content),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // TODO: xử lý thích
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.thumb_up_alt_outlined,
                                              size: 16, color: Colors.black54),
                                          SizedBox(width: 4),
                                          Text(
                                            'Thích',
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    TextButton(
                                      onPressed: () {
                                        widget.onReply(c.id);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Trả lời',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (widget.replyToCommentId == c.id)
                        Padding(
                          padding: const EdgeInsets.only(left: 50, top: 8),
                          child: CommentForm(
                            idPart: widget.postId.toString(),
                            parentCommentId: c.id,
                            isInline: true,
                            onCancelReply: () {
                              widget.onReply(null);
                            },
                          ),
                        ),

                    
                      if (c.replies.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 50, top: 8),
                          child: Column(
                            children: c.replies.map((reply) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: ReplyCommentItem(
                                  comment: reply,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

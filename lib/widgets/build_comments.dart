import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comments_model.dart';
import 'package:flutter_application_1/services/api_service.dart';

class ReplyCommentItem extends StatefulWidget {
  final Comment comment;
  final int postID;

  const ReplyCommentItem({
    super.key,
    required this.comment,
    required this.postID
  });

  @override
  State<ReplyCommentItem> createState() => _ReplyCommentItemState();
}

class _ReplyCommentItemState extends State<ReplyCommentItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(
              'https://vangtran.125.atoz.vn${widget.comment.avatar}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.comment.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${widget.comment.time.day}/${widget.comment.time.month}/${widget.comment.time.year} '
                      '${widget.comment.time.hour}:${widget.comment.time.minute}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(widget.comment.content),
                const SizedBox(width: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await APIService.likeComment(
                          postId: widget.postID,
                          commentId: widget.comment.id,
                        );

                        setState(() {
                          widget.comment.likeCount++;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.thumb_up_alt_outlined,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.comment.likeCount > 0
                                ? 'Thích (${widget.comment.likeCount})'
                                : 'Thích',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comments_model.dart';

class ReplyCommentItem extends StatelessWidget {
  final Comment comment;

  const ReplyCommentItem({
    super.key,
    required this.comment,
  });

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
              'https://vangtran.125.atoz.vn${comment.avatar}',
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
                      comment.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${comment.time.day}/${comment.time.month}/${comment.time.year} '
                      '${comment.time.hour}:${comment.time.minute}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content),
                const SizedBox(width: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: xử lý thích
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.thumb_up_alt_outlined,
                              size: 16, color: Colors.black54),
                          SizedBox(width: 4),
                          Text(
                            'Thích',
                            style: TextStyle(color: Colors.black54),
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:flutter_application_1/widgets/build_input.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CommentForm extends StatefulWidget {
  final int? parentCommentId;
  final VoidCallback? onCancelReply;
  final VoidCallback? onCommentSuccess;
  final bool isInline;
  final String idPart;
  const CommentForm(
      {super.key,
      required this.idPart,
      this.isInline = false,
      this.onCancelReply,
      this.onCommentSuccess,
      this.parentCommentId});

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isSubmitting = false;

  void _handleResult(Map<String, dynamic> result) {
    final thongBao = result['ThongBao'] ?? 'Có lỗi';
    final maLoi = result['maloi'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(thongBao),
        backgroundColor: maLoi == '1' ? Colors.green : Colors.red,
      ),
    );

    if (maLoi == '1') {
      FocusManager.instance.primaryFocus?.unfocus();
      _commentController.clear();
      setState(() => _rating = 0);
      widget.onCommentSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: BuildInput(
                      controller: _nameController,
                      hint: 'Họ tên',
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: BuildInput(
                      controller: _emailController,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: BuildInput(
                      controller: _phoneController,
                      hint: 'Điện thoại',
                      keyboardType: TextInputType.phone,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Viết bình luận của bạn...',
                  hintStyle: const TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                widget.parentCommentId != null
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onCancelReply?.call();
                          },
                          label: const Text('Hủy',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black38,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: RatingBar.builder(
                          initialRating: _rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 35,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 2.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rating = rating;
                            });
                          },
                        ),
                      ),
                Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (!mounted) return;

                            setState(() => _isSubmitting = true);

                            try {
                              final result = await APIService.sendComments(
                                idPart: widget.idPart,
                                tenkh: _nameController.text,
                                sdt: _phoneController.text,
                                email: _emailController.text,
                                noidung: _commentController.text,
                                sosao: _rating,
                                l: widget.parentCommentId,
                              );

                              if (!mounted) return;

                              final requireCaptcha =
                                  result['RequireCaptcha'] == 1 ||
                                      result['RequireCaptcha'] == '1' ||
                                      result['RequireCaptcha'] == true;

                              if (requireCaptcha) {
                                final token = await showCaptchaDialog(
                                  context: context,
                                  message: result['ThongBao'],
                                  captchaCode: result['CaptchaCode'],
                                  action: 'comment'
                                );

                                if (token == null) return;

                                final retry = await APIService.sendComments(
                                  idPart: widget.idPart,
                                  tenkh: _nameController.text,
                                  sdt: _phoneController.text,
                                  email: _emailController.text,
                                  noidung: _commentController.text,
                                  sosao: _rating,
                                  l: widget.parentCommentId,
                                  antiBotToken: token,
                                );

                                if (!mounted) return;

                                _handleResult(retry);
                                return;
                              }

                              _handleResult(result);
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    label: const Text('Gửi',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ])
            ],
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:flutter_application_1/widgets/button_widget.dart';
import 'package:flutter_application_1/widgets/input_widget.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _textFocus = FocusNode();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  bool _isSubmitting = false;
  String? _antiBotToken;
  void _handleResult(Map<String, dynamic> result) {
    if (result['maloi'] == '1') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['ThongBao'] ?? 'Gửi thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['ThongBao'] ?? 'Gửi thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.037;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.apartment, 'Công ty TNHH Chồi Xanh Media',
                    '', fontSize),
                SizedBox(height: 8),
                _buildInfoRow(
                    Icons.location_on,
                    '82A-82B Dân Tộc, Quận Tân Phú, TP. Hồ Chí Minh',
                    '',
                    fontSize),
                SizedBox(height: 8),
                _buildInfoRow(
                    Icons.phone, 'Điện thoại:', '028 3974 3179', fontSize),
                SizedBox(height: 8),
                _buildInfoRow(
                    Icons.email, 'Email:', 'info@Tuyennhansu.com', fontSize),
                SizedBox(height: 8),
                _buildInfoRow(
                    Icons.language, 'Website:', 'TuyenNhanSu.com', fontSize),
                SizedBox(height: 20),
                CustomTextField(
                    controller: _nameCtrl,
                    focusNode: _fullNameFocus,
                    nextFocusNode: _emailFocus,
                    label: 'Họ tên'),
                SizedBox(height: 10),
                CustomTextField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    nextFocusNode: _addressFocus,
                    label: 'Địa chỉ email'),
                SizedBox(height: 10),
                CustomTextField(
                    controller: _addressCtrl,
                    focusNode: _addressFocus,
                    nextFocusNode: _phoneFocus,
                    label: 'Địa chỉ'),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                          controller: _phoneCtrl,
                          focusNode: _phoneFocus,
                          nextFocusNode: _codeFocus,
                          label: 'Điện thoại'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                          focusNode: _codeFocus,
                          nextFocusNode: _textFocus,
                          label: 'Mã xác nhận'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                CustomTextField(
                    controller: _contentCtrl,
                    focusNode: _textFocus,
                    label: 'Nội dung',
                    maxline: 3),
                SizedBox(height: 30),
                CustomButton(
                  text: _isSubmitting ? 'Đang gửi...' : 'Gửi đi',
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!mounted) return;

                          setState(() => _isSubmitting = true);

                          try {
                            // Bước 1: Gửi request ban đầu với antiBotToken (nếu có)
                            final result = await APIService.sendLienHe(
                              linkLienHe: '${APIService.baseUrl}/lien-he-60761',
                              customerName: _nameCtrl.text,
                              emailAddress: _emailCtrl.text,
                              address: _addressCtrl.text,
                              tel: _phoneCtrl.text,
                              notice: _contentCtrl.text,
                              antiBotToken: _antiBotToken,
                            );

                            if (!mounted) return;

                            // Bước 2: Kiểm tra xem có yêu cầu CAPTCHA hay không
                            final requireCaptcha =
                                result['RequireCaptcha'] == 1 ||
                                    result['RequireCaptcha'] == '1' ||
                                    result['RequireCaptcha'] == true;

                            if (requireCaptcha) {
                              // Bước 3: Hiển thị CAPTCHA dialog để người dùng xác minh
                              final token = await showCaptchaDialog(
                                context: context,
                                message:
                                    result['ThongBao'] ?? 'Vui lòng xác minh',
                                captchaCode: result['CaptchaCode'],
                                action: 'lienhe',
                              );

                              if (token == null)
                                return; // Nếu không có token CAPTCHA, không gửi lại dữ liệu

                              // Bước 4: Gửi lại yêu cầu với antiBotToken mới sau khi CAPTCHA xác minh thành công
                              final retry = await APIService.sendLienHe(
                                linkLienHe:
                                    '${APIService.baseUrl}/lien-he-60761',
                                customerName: _nameCtrl.text,
                                emailAddress: _emailCtrl.text,
                                address: _addressCtrl.text,
                                tel: _phoneCtrl.text,
                                notice: _contentCtrl.text,
                                antiBotToken:
                                    token, // Gửi lại với token CAPTCHA mới
                              );

                              if (!mounted) return;

                              // Xử lý kết quả trả về sau khi gửi lại
                              _handleResult(retry);
                              return;
                            }

                            // Nếu không yêu cầu CAPTCHA, xử lý kết quả trả về ban đầu
                            _handleResult(result);
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String textStart, String? textEnd, double fontSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: fontSize + 4),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: textStart,
              style: TextStyle(fontSize: fontSize, color: Colors.black),
              children: [
                if (textEnd != null && textEnd.isNotEmpty)
                  TextSpan(
                    text: " $textEnd",
                    style: TextStyle(fontSize: fontSize, color: Colors.blue),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

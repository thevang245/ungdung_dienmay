import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PayOSQrScreen extends StatelessWidget {
  final double amount;
  final String description;

  const PayOSQrScreen({super.key, required this.amount, required this.description});

  @override
  Widget build(BuildContext context) {
    // Ở thực tế bạn sẽ gọi API backend để tạo QR PayOS
    final qrData =
        "https://api-merchant.payos.vn/v2/gateway/qr?amount=${amount.toInt()}&orderInfo=$description";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán qua PayOS"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            Text(
              "Quét mã QR để thanh toán\nSố tiền: ${amount.toInt()}₫",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/view/cart/address_edit.dart';
import 'package:flutter_application_1/view/cart/bottom_bar.dart';
import 'package:flutter_application_1/view/cart/cart_item.dart';
import 'package:flutter_application_1/view/cart/payos_qrscreen.dart';
import 'package:flutter_application_1/view/cart/product_item.dart';
import 'package:flutter_application_1/view/until/cart_ulti.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:flutter_application_1/widgets/cart_widget.dart';
import 'package:flutter_application_1/widgets/widget_auth.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final List<CartItemModel> item;

  const CheckoutPage(
      {super.key, required this.item, required this.totalAmount});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPayment = "cod";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Xác nhận thanh toán",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: gradientBackground),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Địa chỉ giao hàng
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditAddressScreen()),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: Colors.black),
                              children: [
                                TextSpan(text: "Nguyễn Văn A  •  "),
                                TextSpan(
                                  text: "0987456321",
                                  style: TextStyle(color: Colors.black38),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "123 Đường ABC, Quận 1, TP.HCM",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black38,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            // Thông tin sản phẩm
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.item.length,
                  itemBuilder: (context, index) {
                    final item = widget.item[index];
                    return ProductItemWidget(item: item);
                  }),
            ),

            // Phương thức thanh toán

            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phương thức thanh toán",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // COD option
                  InkWell(
                    onTap: () {
                      setState(() => selectedPayment = "cod");
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text("Thanh toán khi nhận hàng (COD)",
                              style: TextStyle(fontSize: 14)),
                        ),
                        Radio<String>(
                          value: "cod",
                          groupValue: selectedPayment,
                          activeColor: Colors.red,
                          onChanged: (value) {
                            setState(() => selectedPayment = value!);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bank option
                  InkWell(
                    onTap: () {
                      setState(() => selectedPayment = "bank");
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance, color: Colors.green),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text("Chuyển khoản ngân hàng (QR Code)",
                              style: TextStyle(fontSize: 14)),
                        ),
                        Radio<String>(
                          value: "bank",
                          groupValue: selectedPayment,
                          activeColor: Colors.red,
                          onChanged: (value) {
                            setState(() => selectedPayment = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chi tiết thanh toán",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    buildInfoRow(
                        "Tiền đơn hàng",
                        formatCurrency(calculateTotalPrice(widget.item)
                                .toStringAsFixed(0)) +
                            "₫"),
                    const SizedBox(height: 8),
                    buildInfoRow("Phí vận chuyển", '${formatCurrency(30000)}₫'),
                    const Divider(height: 20, color: Colors.black12),
                    buildInfoRow("Tổng thanh toán",
                        '${formatCurrency(widget.totalAmount + 30000)}₫',
                        isTotal: true),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
      bottomNavigationBar: CartBottomBar(
        tongThanhToan: widget.totalAmount + 30000,
        onOrderPressed: () {
          if (selectedPayment == "cod") {
            // COD
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đặt hàng thành công!"),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          } else if (selectedPayment == "bank") {
            // Bank chuyển qua PayOS QR
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PayOSQrScreen(
                  amount: widget.totalAmount + 30000,
                  description: "Thanh toán đơn hàng",
                ),
              ),
            );
          }
        },
        item: widget.item,
        order: true,
      ),
    );
  }
}

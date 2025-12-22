import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/view/cart/confirm_order.dart';
import 'package:flutter_application_1/view/until/until.dart';

class CartBottomBar extends StatelessWidget {
  final double tongThanhToan;
  final VoidCallback onOrderPressed;
  final bool isOrderEnabled;
  final List<CartItemModel> item;
  final bool order;

  const CartBottomBar({
    super.key,
    required this.tongThanhToan,
    required this.onOrderPressed,
    this.isOrderEnabled = false,
    required this.item,
    this.order = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: (isOrderEnabled || order)
                            ? appColor
                            : const Color(0xff99bbff),
                        width: 12)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tổng tiền hàng',
                    style: TextStyle(fontSize: 12, color: Color(0xff0066FF)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatCurrency(tongThanhToan)}đ',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (isOrderEnabled || order) {
                    onOrderPressed();
                  } else {
                    showToast('Vui lòng chọn ít nhất 1 sản phẩm',
                        backgroundColor: Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (isOrderEnabled || order)
                      ? appColor
                      : const Color(0xff99bbff), // xanh nhạt khi disable
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(50))),
                  elevation: 0,
                ),
                child: Center(
                  child: Text(
                    order ? 'Đặt hàng' : 'Mua hàng',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

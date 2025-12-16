import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/cart_service.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:flutter_application_1/view/until/until.dart';

class BottomActionBar extends StatelessWidget {
  final int productId;
  final String userId;
  final String passwordHash;
  final String tieude;
  final String gia;
  final String hinhdaidien;
  final ValueNotifier<int> cartitemCount;
  final String moduleType;
  // final void Function(int?) gotoCart;

  const BottomActionBar({
    super.key,
    required this.productId,
    required this.userId,
    required this.passwordHash,
    required this.tieude,
    required this.gia,
    required this.hinhdaidien,
    required this.cartitemCount,
    required this.moduleType,
    // required this.gotoCart
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: appColor,
                      width: 7,
                    ),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    print('emailaddress: ${Global.email}');
                    final result = await APICartService.addToCart(
                        moduleType: moduleType,
                        emailAddress: Global.email,
                        password: passwordHash,
                        productId: productId,
                        cartitemCount: cartitemCount,
                        quantity: 1);

                    if (result == null) {
                      showToast('Thêm vào giỏ hàng thành công!');
                    } else {
                      showToast(result as String, backgroundColor: Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xff0066FF),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const RoundedRectangleBorder(
                      
                      borderRadius: BorderRadius.only(
                        bottomRight:
                            Radius.circular(30), 
                            bottomLeft: Radius.circular(30)
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 20, color: appColor),
                      SizedBox(height: 2),
                      Text(
                        'Thêm vào giỏ hàng',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xff0066FF)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await APICartService.addToCart(
                      moduleType: moduleType,
                      emailAddress: userId,
                      password: Global.pass,
                      productId: productId as int,
                      cartitemCount: cartitemCount,
                      quantity: 1);
                  // gotoCart(productId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                     
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Center(
                  child: Text(
                    'Mua ngay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

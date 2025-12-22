import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/provider/profileProvider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/cart_local.dart';
import 'package:flutter_application_1/services/cart_service.dart';
import 'package:flutter_application_1/view/allpage.dart';
import 'package:flutter_application_1/view/cart/bottom_bar.dart';
import 'package:flutter_application_1/view/cart/cart_item.dart';
import 'package:flutter_application_1/view/cart/confirm_order.dart';
import 'package:flutter_application_1/view/cart/formorder.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:flutter_application_1/view/until/cart_ulti.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:flutter_application_1/widgets/cart_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  final ValueNotifier<int> cartitemCount;
  const CartPage({super.key, required this.cartitemCount});

  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  List<CartItemModel> cartItems = [];
  bool isSelectAll = false;
  bool isLoading = true;
  bool isOrdering = false;
  late BuildContext rootContext;

  final addressController = TextEditingController();
  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  bool get hasSelectedItems => cartItems.any((item) => item.isSelect);

  double get tongThanhToan {
    final totalPrice = calculateTotalPrice(cartItems);
    return totalPrice.toDouble();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await loadCartItems();
    emailController.text = Global.email;
    fullnameController.text = Global.name;
  }

  Future<void> loadCartItems() async {
    try {
      // 🔹 Giữ lại trạng thái checkbox đã chọn
      final selectedIds = cartItems
          .where((item) => item.isSelect)
          .map((e) => e.id.toString())
          .toSet();

      // 🔹 Load giỏ hàng từ SharedPreferences
      final items = await LocalCartService.getCartItems();

      setState(() {
        cartItems = items.map((e) {
          e.isSelect = selectedIds.contains(e.id.toString());
          return e;
        }).toList();

        isSelectAll =
            cartItems.isNotEmpty && cartItems.every((item) => item.isSelect);

        isLoading = false;
      });

      // 🔹 Update badge từ local
      final total = await LocalCartService.getTotalQuantity();
      widget.cartitemCount.value = total;
    } catch (e) {
      print('❌ Lỗi khi load cart items (LOCAL): $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> chonNhieuVaMoBottomSheet(List<int> productIdsVuaThem) async {
    await loadCartItems();
    await Future.delayed(Duration(milliseconds: 100));

    if (productIdsVuaThem.isNotEmpty) {
      setState(() {
        for (var item in cartItems) {
          int? itemId = int.tryParse(item.id.toString());
          item.isSelect = itemId != null && productIdsVuaThem.contains(itemId);
        }
        isSelectAll = cartItems.every((item) => item.isSelect);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && hasSelectedItems) {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return OrderConfirmationSheet(
                parentContext: context,
                addressController: addressController,
                fullnameController: fullnameController,
                phoneController: phoneController,
                emailController: emailController,
                tongThanhToan: tongThanhToan,
                onConfirm: () async {
                  await showDialog(
                    context: rootContext,
                    barrierDismissible: false,
                    builder: (dialogContext) {
                      // Gọi xử lý đơn hàng sau khi dialog đã render
                      Future.delayed(Duration.zero, () async {
                        await handleDatHang(
                          moduletype: cartItems
                              .firstWhere((item) => item.isSelect)
                              .moduleType,
                          totalPrice: tongThanhToan,
                          address: addressController.text,
                          cartitemCount: widget.cartitemCount,
                          context: context,
                          userId: Global.email,
                          customerName: fullnameController.text,
                          email: emailController.text,
                          tel: phoneController.text,
                          cartItems: cartItems,
                          onCartReload: loadCartItems,
                        );

                        if (mounted) {
                          Navigator.of(dialogContext, rootNavigator: true)
                              .pop();
                        }
                      });

                      return const Dialog(
                        backgroundColor: Colors.black87,
                        insetPadding: EdgeInsets.all(80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                  color: Color(0xff0066FF)),
                              SizedBox(height: 16),
                              Text(
                                "Đang xử lý đơn hàng...",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        }
      });
    }
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      isSelectAll = value ?? false;
      for (var item in cartItems) {
        item.isSelect = isSelectAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = cartItems.where((item) => item.isSelect).toList();
    rootContext = context;
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: CircularProgressIndicator(
          color: Color(0xff0066FF),
        )),
      );
    }

    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: RefreshIndicator(
          color: Color(0xff0066FF),
          onRefresh: loadCartItems,
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    if (cartItems.isNotEmpty)
                      CheckboxListTile(
                        title: const Text('Chọn tất cả'),
                        value: isSelectAll,
                        onChanged: toggleSelectAll,
                        activeColor: appColor,
                      ),
                    Expanded(
                      child: cartItems.isEmpty
                          ? const Center(child: Text("Giỏ hàng trống"))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 70),
                              itemCount: cartItems.length + 1,
                              itemBuilder: (context, index) {
                                if (index == cartItems.length) {
                                  return Container();
                                } else {
                                  final item = cartItems[index];
                                  return ItemCart(
                                    cartitemCount: widget.cartitemCount,
                                    userId: Global.email,
                                    item: item,
                                    isSelected: item.isSelect,
                                    onSelectedChanged: (value) {
                                      setState(() {
                                        item.isSelect = value ?? false;
                                        isSelectAll = cartItems
                                            .every((item) => item.isSelect);
                                      });
                                    },
                                    onIncrease: () async {
                                      int productId =
                                          int.tryParse(item.id.toString()) ?? 0;
                                      item.quantity++;
                                      await APICartService
                                          .updateCartItemQuantity(
                                        emailAddress: Global.email,
                                        productId: productId,
                                        newQuantity: item.quantity,
                                      );
                                    },
                                    onDecrease: () async {
                                      if (item.quantity > 1) {
                                        int productId =
                                            int.tryParse(item.id.toString()) ??
                                                0;
                                        item.quantity--;
                                        await APICartService
                                            .updateCartItemQuantity(
                                          emailAddress: Global.email,
                                          productId: productId,
                                          newQuantity: item.quantity,
                                        );
                                      }
                                    },
                                    OnChanged: () async {
                                      await loadCartItems();
                                    },
                                  );
                                }
                              }),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CartBottomBar(
                    order: false,
                    item: selectedItems,
                    isOrderEnabled: hasSelectedItems,
                    tongThanhToan: tongThanhToan,
                    onOrderPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                                item: selectedItems,
                                totalAmount: tongThanhToan),
                          ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

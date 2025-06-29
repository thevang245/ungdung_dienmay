import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/favourite_service.dart';
import 'package:flutter_application_1/view/auth/register.dart';
import 'package:flutter_application_1/view/cart/cart_page.dart';
import 'package:flutter_application_1/view/components/bottom_appbar.dart';
import 'package:flutter_application_1/view/detail/comment_card.dart';
import 'package:flutter_application_1/view/detail/bottom_bar.dart';
import 'package:flutter_application_1/view/detail/detail_description.dart';
import 'package:flutter_application_1/view/detail/detail_imggallery.dart';
import 'package:flutter_application_1/view/detail/detail_pricetitle.dart';
import 'package:flutter_application_1/view/detail/relatednews_card.dart';
import 'package:flutter_application_1/view/detail/relatedproduct_card.dart';
import 'package:flutter_application_1/view/detail/specs_data.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:flutter_application_1/view/profile/profile.dart';
import 'package:flutter_application_1/view/until/technicalspec_detail.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart'; // Dùng để parse chuỗi HTML
import 'package:share_plus/share_plus.dart';

class DetailPage extends StatefulWidget {
  final String productId;
  final ValueNotifier<int> categoryNotifier;
  final ValueNotifier<int> cartitemCount;
  final VoidCallback? onBack;
  final void Function(dynamic product)? onProductTap;
  final String? modelType;
  final void Function(int?) gotoCart;

  const DetailPage(
      {super.key,
      required this.productId,
      required this.categoryNotifier,
      required this.cartitemCount,
      this.onBack,
      this.onProductTap,
      this.modelType,
      required this.gotoCart});

  @override
  State<DetailPage> createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  String? selectedImageUrl;
  String? htmlContent;
  bool isLoadingHtml = true;
  bool isExpanded = false;
  Map<String, dynamic>? productDetail;
  bool isLoading = true;
  bool isBackVisible = true;
  final ScrollController _scrollController = ScrollController();
  // List<dynamic> commentCard = [];
  late String moduleType;
  List<dynamic> _productsRelated = [];

  static String getModuleNameFromCategoryId(int categoryId) {
    if (categoryModules.containsKey(categoryId)) {
      final moduleParts = categoryModules[categoryId];
      if (moduleParts != null && moduleParts.length >= 3) {
        return moduleParts[1];
      } else {
        print('=> Không đủ phần tử hoặc null');
      }
    } else {
      print('=> Không tìm thấy categoryId trong map');
    }
    return '';
  }

  Future<void> loadProductDetail() async {
    final detail = await APIService.fetchProductDetail(
      APIService.baseUrl,
      moduleType,
      widget.productId,
      getDanhSachHinh,
    );
    if (detail != null) {
      final hinhAnhs = getDanhSachHinh(detail);
      setState(() {
        productDetail = detail;
        htmlContent = detail['noidungchitiet'];
        isLoading = false;
        selectedImageUrl = hinhAnhs.isNotEmpty ? hinhAnhs[0] : null;
        isLoadingHtml = false; 
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final categoryModule =
        getModuleNameFromCategoryId(widget.categoryNotifier.value);

    if ((widget.modelType ?? '').isEmpty) {
      moduleType = categoryModule;
    } else {
      moduleType = widget.modelType!;
    }

    print(
        'categoryWidget: ${widget.modelType} , categoryModule: $categoryModule ,moduleType: $moduleType');

    getProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (isBackVisible) setState(() => isBackVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!isBackVisible) setState(() => isBackVisible = true);
      }
    });

    loadProductDetail();
  }

  void getProducts() async {
    List<dynamic> products = await APIService.getProductRelated(
      id: widget.productId,
      modelType: moduleType,
    );

    final enhancedProducts = products.map((item) {
      return {
        ...item as Map<String, dynamic>,
        'moduleType': moduleType,
      };
    }).toList();

    setState(() {
      _productsRelated = enhancedProducts;
    });
  }

  

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white, title: const Text("Đang tải...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    var model = moduleType;
    final product = productDetail ?? {};
    final hinhAnhs = getDanhSachHinh(product);
    final String title = product['tieude'] ?? 'Sản phẩm chưa có tên';
    final String price = product['gia'] ?? 'Chưa có giá';
    final String description = (product['noidungchitiet'] ?? 'Không có mô tả')
        .replaceAll("''", '"'); // Chuyển '' => "

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding:
                EdgeInsets.only(bottom: model == 'sanpham' ? 55 : 0, top: 0),
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) => true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // để trống phần appbar
                    if (hinhAnhs.isNotEmpty)
                      DetailImageGallery(
                        images: hinhAnhs,
                        onImageSelected: (url) {
                          setState(() => selectedImageUrl = url);
                        },
                      ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (model == 'sanpham')
                            Text(
                              'Giá: ${formatCurrency(price)}đ',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '$title',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    DetailHtmlContent(
                      htmlContent: description,
                      isLoading: isLoadingHtml,
                      isExpanded: isExpanded,
                      onToggle: () => setState(() => isExpanded = !isExpanded),
                    ),
                    const SizedBox(height: 8),
                    TechnicalSpecs(
                      specs: {
                        for (var entry in productSpecsMapping)
                          entry.key: getNestedTengoi(product, entry.value)
                      },
                    ),
                    if (_productsRelated.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50], // Nền xám nhạt
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Text(
                                model == 'tintuc'
                                    ? 'Tin tức liên quan'
                                    : 'Sản phẩm liên quan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            model == 'tintuc'
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    itemCount: _productsRelated.length,
                                    itemBuilder: (context, index) {
                                      final item = _productsRelated[index];
                                      return RelatedNewsCard(
                                        model: model,
                                        product: item,
                                        onTap: () {
                                          if (widget.onProductTap != null) {
                                            widget.onProductTap!(item);
                                          }
                                        },
                                      );
                                    },
                                  )
                                : SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _productsRelated.length,
                                      itemBuilder: (context, index) {
                                        final item = _productsRelated[index];
                                        return RelatedProductCard(
                                          model: model,
                                          product: item,
                                          onTap: () {
                                            if (widget.onProductTap != null) {
                                              widget.onProductTap!(item);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                    // if (commentCard.isNotEmpty && model != 'tintuc') ...[
                    //   Container(
                    //     color: Colors.grey[50], // màu nền xám nhạt
                    //     padding: const EdgeInsets.symmetric(vertical: 12),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         const Padding(
                    //           padding: EdgeInsets.only(left: 8),
                    //           child: Text(
                    //             'Khách hàng nhận xét',
                    //             style: TextStyle(
                    //               fontSize: 18,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.black,
                    //             ),
                    //           ),
                    //         ),
                    //         const SizedBox(height: 8),
                    //         SizedBox(
                    //           height: 180,
                    //           child: ListView.builder(
                    //             scrollDirection: Axis.horizontal,
                    //             itemCount: commentCard.length,
                    //             itemBuilder: (context, index) {
                    //               final comment = commentCard[index];
                    //               return CommentCard(
                    //                 name: comment['tieude'] ?? 'Ẩn danh',
                    //                 content: parseHtmlString(
                    //                     comment['noidungtomtat'] ?? ''),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ],
                    // if (commentCard.isNotEmpty && model != 'tintuc') ...[
                    //   Container(
                    //     color: Colors.grey[50],
                    //     padding: const EdgeInsets.symmetric(vertical: 12),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         const Padding(
                    //           padding: EdgeInsets.only(left: 8),
                    //           child: Text(
                    //             'Khách hàng nhận xét',
                    //             style: TextStyle(
                    //               fontSize: 18,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.black,
                    //             ),
                    //           ),
                    //         ),
                    //         const SizedBox(height: 8),
                    //         SizedBox(
                    //           height: 180,
                    //           child: ListView.builder(
                    //             scrollDirection: Axis.horizontal,
                    //             itemCount: commentCard.length,
                    //             itemBuilder: (context, index) {
                    //               final comment = commentCard[index];
                    //               return CommentCard(
                    //                 name: comment['tieude'] ?? 'Ẩn danh',
                    //                 content: parseHtmlString(
                    //                     comment['noidungtomtat'] ?? ''),
                    //               );
                    //             },
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isBackVisible ? 1.0 : 0.0,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          }
                        },
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.white),
                        onPressed: () async {
                          await APIFavouriteService.toggleFavourite(
                            moduleType: moduleType,
                            context: context,
                            userId: Global.email,
                            productId: int.tryParse(widget.productId) ?? 0,
                            tieude: product['tieude'],
                            gia: product['gia'],
                            hinhdaidien:
                                '${product['hinhdaidien']}',
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: IconButton(
                        icon:
                            Image.asset('asset/share.png', color: Colors.white),
                        onPressed: () async {
                          final productLink =
                              '${APIService.baseUrl}/${product['url']}';
                          final message =
                              'Check out this awesome product: $productLink';
                          await Share.share(message);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (model == 'sanpham' &&
              (productDetail?['gia'] ?? '').toString().trim().isNotEmpty &&
              hinhAnhs.isNotEmpty)
            BottomActionBar(
              gotoCart: widget.gotoCart,
              moduleType: moduleType,
              tieude: product['tieude'],
              gia: product['gia'],
              hinhdaidien: product['hinhdaidien'],
              productId: int.tryParse(widget.productId) ?? 0,
              userId: Global.email,
              passwordHash: Global.pass,
              cartitemCount: widget.cartitemCount,
            ),
        ],
      ),
    );
  }
}

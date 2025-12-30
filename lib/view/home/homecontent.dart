import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/provider/homeProvider.dart';
import 'package:flutter_application_1/view/components/news_card.dart';
import 'package:flutter_application_1/view/components/product_card.dart';
import 'package:flutter_application_1/view/contact/contact.dart';
import 'package:flutter_application_1/view/drawer/filter_bottomsheet.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Homecontent extends StatelessWidget {
 final ValueNotifier<int> filterNotifier;

  const Homecontent({Key? key, required this.filterNotifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final int categoryId = homeProvider.categoryId;
    final String kieuhienthi = homeProvider.kieuhienthi;
    final bool isLoading = homeProvider.isLoading;
    final List<dynamic> products = homeProvider.products;
    final Map<String, dynamic> danhMucData = homeProvider.danhMucData;
    final String categoryName = homeProvider.categoryName;
    final String idCatalog = homeProvider.idCatalogInitial;

    const List<int> singleColumnCategories = [35139, 35142, 35149];
    final crossAxisCount = singleColumnCategories.contains(categoryId) ? 1 : 2;
    final modules = categoryModules[categoryId];
    final isTinTuc = modules != null && modules[1] == 'tintuc';
    final isLienhe = modules != null && modules[1] == 'Lienhe';
    final labelWidth = 190.0;
    final screenWidth = MediaQuery.of(context).size.width;
    print('islienhe: ${isLienhe}');

    print('isTinTuc: ${isTinTuc}');

   

    Widget buildEmptyMessage() {
      return const Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    Widget buildProductGrid(List<dynamic> items, int crossAxisCount) {
      return MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items[index];
          return singleColumnCategories.contains(categoryId)
              ? NewsCard(product: product, categoryId: categoryId)
              : ProductCard(product: product, categoryId: categoryId, kieuhienthi: kieuhienthi,);
        },
      );
    }

    Widget buildGroupedProducts() {
      final Map<int, List<dynamic>> grouped = {};
      for (var p in products) {
        final catId = p['categoryId'] ?? 35001;
        grouped.putIfAbsent(catId, () => []).add(p);
      }

      return ListView(
        padding: const EdgeInsets.all(8.0),
        children: grouped.entries.map((entry) {
          final catId = entry.key;
          final productList = entry.value
              .where((p) => catId == 35004 || hasValidImage(p))
              .toList();
          if (catId == 35149 || productList.isEmpty) return const SizedBox.shrink();

          final catName = homeProvider.findCategoryNameById(danhMucData, catId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPaint(
                painter: CategoryLabelPainter(labelWidth: labelWidth),
                child: Container(
                  height: 30,
                  width: screenWidth,
                  padding: const EdgeInsets.only(left: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    catName.isNotEmpty ? catName : 'Danh mục',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: singleColumnCategories.contains(catId) ? 1 : 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final product = productList[index];
                  return singleColumnCategories.contains(catId)
                      ? NewsCard(product: product, categoryId: catId)
                      : ProductCard(product: product, categoryId: catId, kieuhienthi: kieuhienthi);
                },
              ),
            ],
          );
        }).toList(),
      );
    }

    Widget bodyContent;

    if (categoryId == 60761) {
      bodyContent = ContactForm();
     
    }
    else if (isLoading) {
      bodyContent = const Center(
          child: CircularProgressIndicator(color: Color(0xff0066FF)));
    }
     else if (products.isEmpty) {
      bodyContent = buildEmptyMessage();
    } else if (categoryId == 0) {
      bodyContent = SafeArea(
        child: RefreshIndicator(
          color: const Color(0xff0066FF),
          onRefresh: () async => context.read<HomeProvider>().fetchProducts(force: true),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.search_outlined,
                          color: Color(0xff0066FF), size: 24),
                      Text(
                        'Kết quả tìm kiếm',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Expanded(child: buildProductGrid(products, 1)),
              ],
            ),
          ),
        ),
      );
    } else if (categoryId == 35001) {
      bodyContent = RefreshIndicator(
        color: const Color(0xff0066FF),
        onRefresh: () async => context.read<HomeProvider>().fetchProducts(),
        child: buildGroupedProducts(),
      );
    }
     else {
      final visibleProducts = products
          .where((p) => categoryId == 35004 || hasValidImage(p))
          .toList();
      bodyContent = RefreshIndicator(
        color: const Color(0xff0066FF),
        onRefresh: () async => context.read<HomeProvider>().fetchProducts(),
        child: visibleProducts.isEmpty
            ? ListView(
                children: [const SizedBox(height: 200), buildEmptyMessage()])
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildProductGrid(visibleProducts, crossAxisCount),
              ),
      );
    }

    return Scaffold(
      appBar: (categoryId != 0 && categoryId != 35001)
          ? AppBar(
              backgroundColor: Colors.white,
              titleSpacing: 8,
              title: CustomPaint(
                painter: CategoryLabelPainter(labelWidth: labelWidth),
                child: Container(
                  height: 30,
                  width: screenWidth,
                  padding: const EdgeInsets.only(left: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isLienhe ? categoryName : (!isLoading ? categoryName : 'Đang tải...'),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                
                if (!isTinTuc && categoryId != 60761)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 25,
                      icon: const Icon(Icons.filter_alt, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => BoLocBottomSheet(
                            idCatalog: idCatalog,
                            filterNotifier: filterNotifier,
                            onFilterSelected: (String idfilter) {
                              context
                                  .read<HomeProvider>()
                                  .applyFilter(idfilter);
                            },
                          ),
                        );
                      },
                    ),
                  ),

            
              ],
            )
          : null,
      backgroundColor: Colors.grey[100],
      body: bodyContent,
    );
  }
}
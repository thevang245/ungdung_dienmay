import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/models/category_selection.dart';
import 'package:flutter_application_1/provider/homeProvider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/view/components/news_card.dart';
import 'package:flutter_application_1/view/detail/comment_card.dart';
import 'package:flutter_application_1/view/components/product_card.dart';
import 'package:flutter_application_1/view/contact/contact.dart';
import 'package:flutter_application_1/view/detail/detail_page.dart';
import 'package:flutter_application_1/view/drawer/category_drawer.dart';
import 'package:flutter_application_1/view/drawer/filter_bottomsheet.dart';
import 'package:flutter_application_1/view/home/homecontent.dart';
import 'package:flutter_application_1/view/until/technicalspec_item.dart';
import 'package:flutter_application_1/view/until/until.dart';
import 'package:flutter_application_1/widgets/button_widget.dart';
import 'package:flutter_application_1/widgets/input_widget.dart';
import 'package:flutter_application_1/widgets/widget_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final ValueNotifier<CategorySelection> categoryNotifier;

  final ValueNotifier<int> filterNotifier;

  const HomePage({
    Key? key,
    required this.categoryNotifier,
    required this.filterNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CategorySelection>(
      valueListenable: categoryNotifier,
      builder: (context, selection, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final homeProvider = context.read<HomeProvider>();

          if (homeProvider.categoryId != selection.id ||
              homeProvider.kieuhienthi != selection.kieuHienThi) {
            homeProvider.changeCategory(
              categoryId: selection.id,
              kieuhienthi: selection.kieuHienThi,
            );

            homeProvider.fetchProducts(force: true);
          }
        });

        return Homecontent(filterNotifier: filterNotifier);
      },
    );
  }
}

class Global {
  static String name = '';
  static String email = '';
  static String pass = '';
}

class CategoryLabelPainter extends CustomPainter {
  final double labelWidth;
  final double notchHeight;

  CategoryLabelPainter({
    required this.labelWidth,
    this.notchHeight = 26,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(labelWidth, notchHeight, size.width - labelWidth,
        size.height - notchHeight);
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(labelWidth - 25, 0);
    path.lineTo(labelWidth, notchHeight);
    path.lineTo(labelWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawRect(rect, paint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

Map<String, dynamic> processCategoryData(List<dynamic> categories) {
  final List<Map<String, dynamic>> safeList =
      categories.map((item) => Map<String, dynamic>.from(item)).toList();

  List<int> getParentCategoryIds(List<Map<String, dynamic>> items) {
    return items.map((e) => int.parse(e['id'].toString())).toList();
  }

  Map<String, dynamic> convertToDanhMucData(List<Map<String, dynamic>> items) {
    Map<String, dynamic> result = {};
    for (var item in items) {
      final id = item['id'].toString();
      final tieude = item['tieude'] ?? 'Danh mục $id';
      result[tieude] = {
        'id': int.parse(id),
        if (item.containsKey('children') && item['children'] is List)
          'children': convertToDanhMucData(
              List<Map<String, dynamic>>.from(item['children'])),
      };
    }
    return result;
  }

  return {
    'ids': getParentCategoryIds(safeList),
    'danhMucData': convertToDanhMucData(safeList),
  };
}

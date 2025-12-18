import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/category_selection.dart';
import 'package:flutter_application_1/models/order_history_model.dart';
import 'package:flutter_application_1/models/product_model.dart';
import 'package:flutter_application_1/provider/detailProvider.dart';
import 'package:flutter_application_1/provider/homeProvider.dart';
import 'package:flutter_application_1/provider/pageStateProvider.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/cart_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/view/auth/login.dart';
import 'package:flutter_application_1/view/auth/register.dart';
import 'package:flutter_application_1/view/cart/cart_history.dart';
import 'package:flutter_application_1/view/cart/cart_page.dart';
import 'package:flutter_application_1/view/components/bottom_appbar.dart';
import 'package:flutter_application_1/view/components/search_appbar.dart';
import 'package:flutter_application_1/view/detail/detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/view/drawer/category_drawer.dart';
import 'package:flutter_application_1/view/drawer/filter_bottomsheet.dart';
import 'package:flutter_application_1/view/favourite/favourite_page.dart';
import 'package:flutter_application_1/view/home/homepage.dart';
import 'package:flutter_application_1/view/profile/profile.dart';
import 'package:provider/provider.dart';

class PageAll extends StatefulWidget {
  const PageAll({super.key});

  @override
  State<PageAll> createState() => _PageAllState();
}

class _PageAllState extends State<PageAll> {
  int _currentIndex = 0;
  String _currentPage = 'home';
  String _previousPage = 'home';

  final ValueNotifier<CategorySelection> categoryNotifier =
      ValueNotifier(CategorySelection(60711, 'sanpham', 'Trang chủ'));

  final ValueNotifier<int> filterNotifier = ValueNotifier(0);
  final ValueNotifier<int> cartItemCountNotifier = ValueNotifier(0);

  final GlobalKey<favouritePageState> favouritePageKey =
      GlobalKey<favouritePageState>();
  final GlobalKey<CartPageState> cartPageKey = GlobalKey<CartPageState>();
  final GlobalKey<CarthistoryPageState> carthistoryPageKey =
      GlobalKey<CarthistoryPageState>();

  final TextEditingController _searchController = TextEditingController();

  HomePage? _homePage;
  favouritePage? _favouritePage;
  CartPage? _cartPage;
  ProfilePage? _profilePage;
  Register? _registerPage;
  CarthistoryPage? _carthistoryPage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      homeProvider.fetchDanhMuc().then((_) {
        homeProvider.fetchProducts(force: true);
      });
    });
  }

  void _onTabTapped(int index) {
    final pageState = context.read<PageStateProvider>();

    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          _currentPage = 'home';
          break;
        case 1:
          _currentPage = 'favourite';
          break;
        case 2:
          _currentPage = 'cart';
          break;
        case 3:
          _currentPage = 'profile';
          break;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (index) {
        // case 1:
        //   favouritePageKey.currentState?.reloadFavourites();
        //   break;
        case 2:
          cartPageKey.currentState?.loadCartItems();
          break;
      }
    });

    pageState.setCurrentIndex(index);
  }

  void _goToCartHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarthistoryPage(
          key: carthistoryPageKey,
          cartitemCount: cartItemCountNotifier,
          gotoCart: (List<int>? productIdsVuaThem) {
            setState(() {
              _currentPage = 'cart';
              _currentIndex = 2;
            });
            cartPageKey.currentState
                ?.chonNhieuVaMoBottomSheet(productIdsVuaThem ?? []);
          },
        ),
      ),
    );
  }

  void _goHome({CategorySelection? newCategory}) {
    setState(() {
      _currentPage = 'home';
      _currentIndex = 0;
      _previousPage = 'home';

      if (newCategory != null) {
        categoryNotifier.value = newCategory;
      }
    });
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return HomePage(
          categoryNotifier: categoryNotifier,
          filterNotifier: filterNotifier,
        );

      case 1:
        return _favouritePage ??= favouritePage(
          key: favouritePageKey,
        );
      case 2:
        return _cartPage ??= CartPage(
          key: cartPageKey,
          cartitemCount: cartItemCountNotifier,
        );
      case 3:
        return _profilePage ??= ProfilePage(
          onTapCartHistory: _goToCartHistory,
          onLogout: () async {
            await AuthService.handleLogout(context);
            setState(() {
              _currentPage = 'home';
              _currentIndex = 0;
              cartItemCountNotifier.value = 0;
              _profilePage = null;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: DanhMucDrawer(
            onCategorySelected: (int id, String kieuhienthi, String tieude) async {
          print('id danh muc: $id');
          await Navigator.of(context).maybePop();
          setState(() {
            _currentPage = 'home';
            _currentIndex = 0;
            _searchController.clear();
            categoryNotifier.value = CategorySelection(id, kieuhienthi, tieude);
          });
        }),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: SearchAppBar(
            controller: _searchController,
            onSearch: (String keyword) {
              setState(() {
                _currentIndex = 0;
                _currentPage = 'home';
                filterNotifier.value++;
              });
              context.read<HomeProvider>().runSearch(keyword);
            },
          ),
        ),
        body: _getCurrentPage(),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          cartitemCount: cartItemCountNotifier.value,
        ),
      ),
    );
  }
}

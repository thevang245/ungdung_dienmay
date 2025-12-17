class CategorySelection {
  final int id;
  final String kieuHienThi;

  CategorySelection(this.id, this.kieuHienThi);
}

class ModuleResolver {
  static const Map<String, List<String>> _map = {
    'Trangchu': ['ww2', 'module', 'sanpham.trangchu'],
    'Sanpham': ['ww2', 'module', 'sanpham'],
    'Tintuc': ['ww2', 'module', 'tintuc'],
  };

  static List<String>? resolve(String kieuHienThi) {
    return _map[kieuHienThi];
  }
}


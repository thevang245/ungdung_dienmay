import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // chỉnh đúng path nếu cần

class BoLocBottomSheet extends StatefulWidget {
  final void Function(int) onFilterSelected;
  final ValueNotifier<int?> filterNotifier;
  final String idCatalog;

  const BoLocBottomSheet({
    super.key,
    required this.onFilterSelected,
    required this.filterNotifier,
    required this.idCatalog,
  });

  @override
  State<BoLocBottomSheet> createState() => _BoLocBottomSheetState();
}

class _BoLocBottomSheetState extends State<BoLocBottomSheet> {
  List<Map<String, dynamic>> filtersWithChildren = [];
  bool isLoading = true;
  String? errorMessage;
  Set<int> selectedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchBoLocIncrementally(idCatalog: widget.idCatalog);
  }

  Future<void> _fetchBoLocIncrementally({required String idCatalog}) async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await APIService.getBoLocByCatalog(idCatalog);

      if (!mounted) return;

      if (response['status'] == 'success' && response['data'] != null) {
        final List<dynamic> filters = response['data']['filters'] ?? [];
        final newFilters = <Map<String, dynamic>>[];

        for (var filter in filters) {
          final title = filter['name'] as String? ?? 'Bộ lọc';
          final List<dynamic> children =
              filter['children'] as List<dynamic>? ?? [];

          if (children.isNotEmpty) {
            newFilters.add({
              'tieude': title,
              'children': children,
            });
          }
        }

        setState(() {
          filtersWithChildren = newFilters;
          selectedIds.clear();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load filters';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error loading filters: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header với background xanh tràn đầy hai bên
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                width: double.infinity, // Tràn đầy chiều rộng
                color: Color(0xFF198754),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bộ lọc",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text("Đóng",
                            style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Phần còn lại với padding
            Expanded(
              child: Container(
                color: Colors.white,
                padding:
                    EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
                child: isLoading && filtersWithChildren.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(child: Text(errorMessage!))
                        : filtersWithChildren.isEmpty
                            ? const Center(child: Text("No filters available"))
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: filtersWithChildren.length,
                                itemBuilder: (context, index) {
                                  final filter = filtersWithChildren[index];
                                  final title = filter['tieude'] as String? ??
                                      'Bộ lọc $index';
                                  final children =
                                      filter['children'] as List<dynamic>? ??
                                          [];

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          children:
                                              children.map<Widget>((child) {
                                            final childTitle =
                                                child['name'] as String? ??
                                                    'Chi tiết';
                                            final int? childId = int.tryParse(
                                                child['idfilter']?.toString() ??
                                                    '');
                                            final bool isSelected = childId !=
                                                    null &&
                                                selectedIds.contains(childId);

                                            return Stack(
                                              children: [
                                                FilterChip(
                                                  label: Text(
                                                    childTitle,
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.black54,
                                                    ),
                                                  ),
                                                  selected: isSelected,
                                                  selectedColor:
                                                      const Color(0xFF198754),
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                  side: BorderSide.none,
                                                  showCheckmark: false,
                                                  onSelected: (selected) {
                                                    if (childId != null) {
                                                      setState(() {
                                                        if (selected) {
                                                          selectedIds
                                                              .add(childId);
                                                        } else {
                                                          selectedIds
                                                              .remove(childId);
                                                        }
                                                      });
                                                    }
                                                  },
                                                ),
                                                if (isSelected)
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      size:
                                                          18, // Small checkmark size
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text(
                  "Áp dụng",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF198754), // xanh lá giống header
                  foregroundColor: Colors.white,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

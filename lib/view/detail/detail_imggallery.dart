import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/detail/img_expand.dart'; // Thay import sang file mới

class DetailImageGallery extends StatefulWidget {
  final List<String> images;
  final Function(String) onImageSelected;

  const DetailImageGallery({
    super.key,
    required this.images,
    required this.onImageSelected,
  });

  @override
  State<DetailImageGallery> createState() => _DetailImageGalleryState();
}

class _DetailImageGalleryState extends State<DetailImageGallery> {
  int currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onImageSelected(int index) {
    setState(() {
      currentIndex = index;
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenGalleryViewer(
                            images: widget.images,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      widget.images[index],
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => onImageSelected(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color:
                          currentIndex == index ? Colors.blue : Colors.black12,
                    ),
                  ),
                  child: Image.network(
                    widget.images[index],
                    width: 80,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

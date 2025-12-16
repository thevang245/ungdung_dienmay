import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/until/until.dart';

class SettingItemCard extends StatelessWidget {
  final IconData icon;
  final IconData? iconRight;
  final String title;
  final VoidCallback? onTap;

  const SettingItemCard({
    super.key,
    required this.icon,
    this.iconRight,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap ?? () {},
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    icon,
                    size: 20,
                    color: appColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
                if (iconRight != null)
                  Icon(iconRight, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


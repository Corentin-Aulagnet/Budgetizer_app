import 'package:flutter/material.dart';

class IconDescriptor {
  late IconData icon;
  late String name;
  late Color color;
  late String fontPackage;
  late String fontFamily;

  IconDescriptor({
    required this.icon,
    required this.name,
  });
  IconDescriptor.createEmpty();

  @override
  String toString() {
    return '{icon : ${icon.codePoint.toString()}, fontFamily: $icon.fontFamily, fontPacakage: $icon.fontPackage, name : $name, color : ${color.toString()}';
  }
}

class IconItem extends StatelessWidget {
  final IconDescriptor icon;
  final Color color;
  const IconItem({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Icon(
              icon.icon,
              color: color,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  icon.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

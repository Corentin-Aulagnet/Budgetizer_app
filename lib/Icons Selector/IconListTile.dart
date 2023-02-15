import 'dart:convert';
import 'package:budgetizer/database_handler.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

class CategoryDescriptor {
  late IconData icon; //used in hash
  late String name; //used in hash
  late List<String> descriptors; //used in hash
  late Color color; // used in hash
  late String fontPackage;
  late String fontFamily;
  late String hash;

  CategoryDescriptor(
      {required this.icon,
      required this.name,
      required this.descriptors,
      required this.color,
      this.fontFamily = '',
      this.fontPackage = ''}) {
    var bytes = utf8.encode(icon.hashCode.toString() +
        name +
        descriptors.join('') +
        color.toString());
    hash = '${sha256.convert(bytes)}';
  }
  CategoryDescriptor.createPlaceholder() {
    this.icon = Icons.image;
    this.name = "Your category";
    this.descriptors = [""];
    this.color = Color(0xff000000);
    this.fontFamily = '';
    this.fontPackage = '';
  }
  CategoryDescriptor.fromJSON(Map<String, dynamic> json)
      : icon = IconData(int.parse(json['icon']),
            fontFamily: json['fontFamily'], fontPackage: json['fontPackage']),
        fontFamily = json['fontFamily'] ?? '',
        fontPackage = json['fontPackage'] ?? '',
        name = json['name'],
        descriptors = List.generate(json['desc'].toString().split('-').length,
            (index) => json['desc'].toString().split('-')[index]),
        color = Color(int.parse('0x${json['color']}')) {
    var bytes = utf8.encode(icon.hashCode.toString() +
        name +
        descriptors.join('') +
        color.toString());
    hash = '${sha256.convert(bytes)}';
  }

  Map<String, dynamic> toJSON() => {
        'icon': icon.codePoint.toString(),
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
        'name': name,
        'desc': descriptors.join('-'),
        'color': color.toString().split('(0x')[1].split(')')[0],
        'hash': hash
      };

  @override
  String toString() {
    return '{icon : ${icon.codePoint.toString()}, fontFamily: $icon.fontFamily, fontPacakage: $icon.fontPackage, name : $name, desc : ${descriptors.join('-')}, color : ${color.toString()}';
  }

  String display() {
    return name;
  }
}

class IconDescriptor {
  late IconData icon;
  late String name;
  late List<String> descriptors;
  late Color color;
  late String fontPackage;
  late String fontFamily;

  IconDescriptor(
      {required this.icon, required this.name, required this.descriptors});
  IconDescriptor.CreateEmpty();

  @override
  String toString() {
    return '{icon : ${icon.codePoint.toString()}, fontFamily: $icon.fontFamily, fontPacakage: $icon.fontPackage, name : $name, desc : ${descriptors.join('-')}, color : ${color.toString()}';
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
    DatabaseHandler.LoadCategories();
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
                Text(
                  icon.descriptors.join('-'),
                  style: const TextStyle(
                    color: Colors.black,
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

class CategoryItem extends StatelessWidget {
  final CategoryDescriptor category;
  final Color color;
  const CategoryItem({
    Key? key,
    required this.category,
    required this.color,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    DatabaseHandler.LoadCategories();
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
              category.icon,
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
                  category.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  category.descriptors.join('-'),
                  style: const TextStyle(
                    color: Colors.black,
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

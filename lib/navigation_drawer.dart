import 'package:flutter/material.dart';

import 'app_colors.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        const UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: AppColors.primaryColor),
          accountName: Text(
            "Test User",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Text(
            "abcd.efgh@domain.com",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          currentAccountPicture: FlutterLogo(),
        ),
        ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"), //TODO Localization
            onTap: () => Navigator.popAndPushNamed(context, '/')),
        ListTile(
            leading: Icon(Icons.format_list_bulleted_rounded),
            title: const Text("Expenses"), //TODO localization
            onTap: () => Navigator.popAndPushNamed(context, '/Expenses')),
        ListTile(
            leading: Icon(Icons.auto_graph),
            title: const Text("Analytics"), //TODO localization
            onTap: () => Navigator.popAndPushNamed(context, '/Analytics')),
        ListTile(
            leading: Icon(Icons.category_rounded),
            title: const Text("Categories"), //TODO localization
            onTap: () => Navigator.popAndPushNamed(context, '/Categories')),
        Spacer(), // <-- This will fill up any free-space
        // Everything from here down is bottom aligned in the drawer
        Divider(),
        ListTile(
            leading: Icon(Icons.settings),
            title: const Text("Options"),
            onTap: () => Navigator.popAndPushNamed(context, '/Options')),
      ],
    ));
  }
}

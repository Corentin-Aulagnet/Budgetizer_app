import 'package:flutter/material.dart';

import 'package:ledgerstats/app_colors.dart';

class AppNavigationDrawer extends StatelessWidget {
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
        AboutListTile(
            icon: const Icon(Icons.info),
            applicationIcon: const FlutterLogo(),
            applicationName: 'Show About Example',
            applicationVersion: 'August 2019',
            applicationLegalese: '\u{a9} 2014 The Flutter Authors',
            aboutBoxChildren: <Widget>[
              const SizedBox(height: 24),
              RichText(
                  text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium!,
                      text:
                          "Flutter is Google's UI toolkit for building beautiful, "
                          'natively compiled applications for mobile, web, and desktop '
                          'from a single codebase. Learn more about Flutter at '),
                  TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                      text: 'https://flutter.dev'),
                  TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium!,
                      text: '.'),
                ],
              ))
            ]),
        ListTile(
            leading: Icon(Icons.settings),
            title: const Text("Options"), //TODO localization
            onTap: () => Navigator.popAndPushNamed(context, '/Options')),
      ],
    ));
  }
}

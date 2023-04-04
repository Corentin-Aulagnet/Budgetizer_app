import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ledgerstats/app_colors.dart';

class AboutBoxChildren extends StatefulWidget {
  const AboutBoxChildren({super.key});
  @override
  _AboutBoxChildrenState createState() => _AboutBoxChildrenState();
}

class _AboutBoxChildrenState extends State<AboutBoxChildren> {
  late TapGestureRecognizer _tapGestureRecognizer;
  final Uri _url =
      Uri.parse('https://github.com/Corentin-Aulagnet/Budgetizer_app/issues');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  void initState() {
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _launchUrl;
  }

  @override
  void dispose() {
    super.dispose();
    _tapGestureRecognizer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle style = theme.textTheme.bodyMedium!;
    return Column(children: <Widget>[
      const SizedBox(height: 24),
      RichText(
          text: TextSpan(
        children: <TextSpan>[
          TextSpan(
              style: style,
              text:
                  "LedgerStats is an application used to manage your expenses, "
                  'you can add, modify, delete expenses quickly and sort them '
                  'in custom categories.\n'
                  'You will also find some analystics about how you spend your '
                  'money, monthly, yearly.\n'
                  'Be careful, it is still being developed, please report any bugs '
                  'or feature you would like to see on our '), //TODO localization
          TextSpan(
            style: style.copyWith(color: theme.colorScheme.primary),
            text: 'GitHub',
            recognizer: _tapGestureRecognizer,
          ),
          TextSpan(style: style, text: '.'),
        ],
      ))
    ]);
  }
}

class AppNavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> aboutBoxChildren = <Widget>[AboutBoxChildren()];
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
          currentAccountPicture:
              Image(image: AssetImage('assets/icon/icon_launcher.png')),
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
            applicationIcon:
                const Image(image: AssetImage('assets/icon/icon_launcher.png')),
            applicationName: 'LedgerStats',
            applicationVersion: '1.0.0 April 2023', //TODO localization
            applicationLegalese: '\u{a9} 2023 Corentin Aulagnet',
            aboutBoxChildren: aboutBoxChildren),
        ListTile(
            leading: Icon(Icons.settings),
            title: const Text("Options"), //TODO localization
            onTap: () => Navigator.popAndPushNamed(context, '/Options')),
      ],
    ));
  }
}

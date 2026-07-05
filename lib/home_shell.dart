import 'package:flutter/material.dart';
// Replaced FontAwesome icons with Material icons to avoid package issues

import 'cart_page.dart';
import 'contact_developer_page.dart';
import 'filepicker_page.dart';
import 'medicine_search_page.dart';
import 'store_locator_page.dart';

class HomeShellPage extends StatefulWidget {
  final int initialIndex;
  final bool contactOpenedDueToApiIssue;

  const HomeShellPage({
    super.key,
    this.initialIndex = 0,
    this.contactOpenedDueToApiIssue = false,
  });

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  late int selectedIndex;

  late final List<Widget> pages = [
    const FilepickerPage(),
    MedicineSearchPage(
      autoRedirectToContact: !widget.contactOpenedDueToApiIssue,
    ),
    StoreLocatorPage(
      autoRedirectToContact: !widget.contactOpenedDueToApiIssue,
    ),
    CartPage(),
    ContactDeveloperPage(
      showIssueBanner: widget.contactOpenedDueToApiIssue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: Colors.green[600],
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.upload_file),
            selectedIcon: Icon(Icons.upload_file, color: Colors.white),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: Colors.white),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: Icon(Icons.store),
            selectedIcon: Icon(Icons.store, color: Colors.white),
            label: 'Kendras',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            selectedIcon: Icon(Icons.list_alt, color: Colors.white),
            label: 'List',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help_outline, color: Colors.white),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}

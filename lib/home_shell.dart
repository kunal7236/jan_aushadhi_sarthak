import 'package:flutter/material.dart';

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
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.upload_file_outlined),
            selectedIcon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Kendras',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'List',
          ),
          NavigationDestination(
            icon: Icon(Icons.contact_support_outlined),
            selectedIcon: Icon(Icons.contact_support),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

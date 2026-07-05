import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            icon: FaIcon(FontAwesomeIcons.fileArrowUp),
            selectedIcon: FaIcon(FontAwesomeIcons.fileArrowUp),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            selectedIcon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.store),
            selectedIcon: FaIcon(FontAwesomeIcons.store),
            label: 'Kendras',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.listCheck),
            selectedIcon: FaIcon(FontAwesomeIcons.listCheck),
            label: 'List',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.addressBook),
            selectedIcon: FaIcon(FontAwesomeIcons.addressBook),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

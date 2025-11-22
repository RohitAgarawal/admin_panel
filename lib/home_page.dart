import 'package:admin_panel/access_code/access_code.dart';
import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/product/all_product_get.dart';
import 'package:admin_panel/provider/tab_provider/tab_provider.dart';
import 'package:admin_panel/report/report_screen.dart';
import 'package:admin_panel/user/user_Screen.dart';
import 'package:admin_panel/about_us/screen/about_us_screen.dart';
import 'package:admin_panel/app_version/app_version.dart';
import 'package:admin_panel/feature_request/feature_request_screen.dart';
import 'package:admin_panel/screens/rating.dart';
import 'package:admin_panel/app_use_guide/screen/app_use_guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home-page";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // int selectedIndex = 0;
  // Widget selectedWidget = Dashboard();

  final List<Widget> _pages = [
    const Dashboard(),
    const AllProductGet(),
    const UserScreen(),
    const AccessCode(),
    const ReportScreen(),
    const AppVersion(),
    const FeatureRequestScreen(),
    const Rating(),
    const Center(child: Text("Chat Under Development")),
    const AboutUsScreen(),
    const AppUseGuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 1000;

          return Row(
            children: [
              Consumer<TabProvider>(
                builder: (context, tabProvider, child) {
                  if (isSmallScreen) {
                    return NavigationRail(
                      selectedIndex: tabProvider.selectedIndex,
                      onDestinationSelected: (int index) {
                        if (index == 11) {
                          // Logout index
                          _logout();
                        } else {
                          tabProvider.setSelectedIndex(index);
                        }
                      },
                      labelType: NavigationRailLabelType.all,
                      leading: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.dashboard),
                          selectedIcon: Icon(
                            Icons.dashboard,
                            color: Colors.green,
                          ),
                          label: Text("Dashboard"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.production_quantity_limits_rounded),
                          selectedIcon: Icon(
                            Icons.production_quantity_limits_rounded,
                            color: Colors.green,
                          ),
                          label: Text("Product"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person),
                          selectedIcon: Icon(Icons.person, color: Colors.green),
                          label: Text("User"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings),
                          selectedIcon: Icon(
                            Icons.settings,
                            color: Colors.green,
                          ),
                          label: Text("Access"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.help),
                          selectedIcon: Icon(Icons.help, color: Colors.green),
                          label: Text("Reports"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.new_releases_rounded),
                          selectedIcon: Icon(
                            Icons.new_releases_rounded,
                            color: Colors.green,
                          ),
                          label: Text("Versions"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.request_page_rounded),
                          selectedIcon: Icon(
                            Icons.request_page_rounded,
                            color: Colors.green,
                          ),
                          label: Text("Features"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.reviews_rounded),
                          selectedIcon: Icon(
                            Icons.reviews_rounded,
                            color: Colors.green,
                          ),
                          label: Text("Reviews"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.support_agent_rounded),
                          selectedIcon: Icon(
                            Icons.support_agent_rounded,
                            color: Colors.green,
                          ),
                          label: Text("Chat"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.info),
                          selectedIcon: Icon(Icons.info, color: Colors.green),
                          label: Text("About"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.menu_book),
                          selectedIcon: Icon(
                            Icons.menu_book,
                            color: Colors.green,
                          ),
                          label: Text("Guide"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.logout, color: Colors.red),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Drawer(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 150,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                _buildDrawerItem(
                                  tabProvider,
                                  0,
                                  Icons.dashboard,
                                  "Dashboard",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  1,
                                  Icons.production_quantity_limits_rounded,
                                  "Product",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  2,
                                  Icons.person,
                                  "User",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  3,
                                  Icons.settings,
                                  "Access Code",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  4,
                                  Icons.help,
                                  "Reports",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  5,
                                  Icons.new_releases_rounded,
                                  "App Versions",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  6,
                                  Icons.request_page_rounded,
                                  "Feature Request",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  7,
                                  Icons.reviews_rounded,
                                  "Reviews/Rate",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  8,
                                  Icons.support_agent_rounded,
                                  "Chat",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  9,
                                  Icons.info,
                                  "About Us",
                                ),
                                _buildDrawerItem(
                                  tabProvider,
                                  10,
                                  Icons.menu_book,
                                  "App Guide",
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.logout,
                                    color: Colors.black,
                                  ),
                                  title: Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: _logout,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              // Main content with IndexedStack for performance
              Expanded(
                child: Consumer<TabProvider>(
                  builder: (context, tabProvider, child) {
                    return IndexedStack(
                      index: tabProvider.selectedIndex,
                      children: _pages,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(
    TabProvider tabProvider,
    int index,
    IconData icon,
    String title,
  ) {
    bool isSelected = tabProvider.selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.green : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.green : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.green.shade100,
      onTap: () {
        tabProvider.setSelectedIndex(index);
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Logout", style: TextStyle(color: Colors.black)),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                AdminSharedPreferences().logout();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}

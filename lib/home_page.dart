import 'package:admin_panel/access_code/access_code.dart';
import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/product/all_product_get.dart';
import 'package:admin_panel/provider/tab_provider/tab_provider.dart';
import 'package:admin_panel/report/report_screen.dart';
import 'package:admin_panel/user/user_Screen.dart';
import 'package:animations/animations.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Consumer<TabProvider>(
            builder: (context,tabProvider, child) {
              return Drawer(
                backgroundColor: Colors.white,
                elevation: 2,
                child: Column(
                  spacing: 10,
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
                    ListTile(
                      leading: Icon(
                        Icons.dashboard,
                        color: tabProvider.selectedIndex == 0 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "Dashboard",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 0 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 0,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                        tabProvider.setSelectedIndex(0);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.production_quantity_limits_rounded,
                        color: tabProvider.selectedIndex == 1 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "Product",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 1 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 1,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                        tabProvider.setSelectedIndex(1);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: tabProvider.selectedIndex == 2 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "User",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 2 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 2,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                       tabProvider.setSelectedIndex(2);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: tabProvider.selectedIndex == 3 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "Access Code",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 3 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 3,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                        tabProvider.setSelectedIndex(3);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help,
                        color: tabProvider.selectedIndex == 4 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "Reports",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 4 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 4,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                        tabProvider.setSelectedIndex(4);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.new_releases_rounded,
                        color: tabProvider.selectedIndex == 5 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "App Versions",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 5 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 5,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                        tabProvider.setSelectedIndex(5);
                      },
                    ),
                    /// TODO: new feature request
                    ListTile(
                      leading: Icon(
                        Icons.request_page_rounded,
                        color: tabProvider.selectedIndex == 6 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "Feature Request",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 6 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 6,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                        tabProvider.setSelectedIndex(6);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.support_agent_rounded,
                        color: tabProvider.selectedIndex == 8 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "Chat",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 8 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 8,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                        tabProvider.setSelectedIndex(8);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.reviews_rounded,
                        color: tabProvider.selectedIndex == 7 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "Reviews/Rate",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 7 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 7,
                      selectedTileColor: Colors.green.shade100,
                      onTap: () {
                        tabProvider.setSelectedIndex(7);
                      },
                    ),
                    ListTile(
                        leading: Icon(
                          Icons.info,
                          color: tabProvider.selectedIndex == 9 ? Colors.green : Colors.black,
                        ),
                        title: Text(
                          "About Us",
                          style: TextStyle(
                            color: tabProvider.selectedIndex == 9 ? Colors.green : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: tabProvider.selectedIndex == 9,
                        selectedTileColor: Colors.green.shade100,
                        onTap: (){
                          tabProvider.setSelectedIndex(9);
                        }
                    ),
                    ListTile(
                        leading: Icon(
                          Icons.menu_book,
                          color: tabProvider.selectedIndex == 10 ? Colors.green : Colors.black,
                        ),
                        title: Text(
                          "App Guide",
                          style: TextStyle(
                            color: tabProvider.selectedIndex == 10 ? Colors.green : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: tabProvider.selectedIndex == 10,
                        selectedTileColor: Colors.green.shade100,
                        onTap: (){
                          tabProvider.setSelectedIndex(10);
                        }
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: tabProvider.selectedIndex == 11 ? Colors.green : Colors.black,
                      ),
                      title: Text(
                        "Logout",
                        style: TextStyle(
                          color: tabProvider.selectedIndex == 11 ? Colors.green : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: tabProvider.selectedIndex == 11,
                      selectedTileColor: Colors.green.shade100,
                      onTap: (){
                        _logout();
                      }
                    ),
                  ],
                ),
              );
            }
          ),
          // Main content
          Consumer<TabProvider>(
            builder: (context,tabProvider, child) {
              return Expanded(
                child: Container(
                  // color: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 400),
                    reverse: tabProvider.lastIndex > tabProvider.selectedIndex,
                    transitionBuilder: (child, animation, secondaryAnimation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(tabProvider.lastIndex < tabProvider.selectedIndex ? 0.2 : -0.2, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(tabProvider.selectedIndex),
                      child: tabProvider.selectedWidget,
                    ),
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }



  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Logout",style: TextStyle(color: Colors.black),),
          content:  Text("Are you sure you want to logout?",style: TextStyle(color: Colors.black),),
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



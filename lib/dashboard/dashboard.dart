import 'package:admin_panel/dashboard/dashboard_section.dart';
import 'package:admin_panel/dashboard/dashboard_stats_card.dart';
import 'package:admin_panel/provider/dashboard_provider/total_user_provider.dart';
import 'package:admin_panel/provider/product_provider/product_provider.dart';
import 'package:admin_panel/provider/report_provider/report_provider.dart';
import 'package:admin_panel/provider/tab_provider/tab_provider.dart';
import 'package:admin_panel/provider/user_provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  static const routeName = "/dashboard-screen";

  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        Provider.of<TotalUserProvider>(context, listen: false).userCount(),
        Provider.of<ReportProvider>(context, listen: false).reportCount(),
      ]);
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void navigateToProductsScreen({String category = ""}) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final tabProvider = Provider.of<TabProvider>(context, listen: false);

    productProvider.setSelectedCategory(category);
    tabProvider.setSelectedIndex(1);
  }

  void _navigateToUserTab(String category, String status) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tabProvider = Provider.of<TabProvider>(context, listen: false);

    userProvider.setSelectedCategory(category);
    userProvider.setStatusFilter(status);
    userProvider.getUser();
    tabProvider.setSelectedIndex(2);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<TotalUserProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6F61EF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFF6F61EF),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard Overview",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Welcome back to your admin panel",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Total Users Section
              DashboardSection(
                title: "User Statistics",
                titleColor: Colors.blue,
                children: [
                  DashboardStatsCard(
                    title: "Total Users",
                    count: userProvider.totalUser.toString(),
                    color: Colors.blue,
                    icon: Icons.group,
                    onTap: () => _navigateToUserTab("", ""),
                  ),
                  DashboardStatsCard(
                    title: "Verified",
                    count: userProvider.verifiedUser.toString(),
                    color: Colors.green,
                    icon: Icons.verified_user,
                    onTap: () => _navigateToUserTab("", "Verified"),
                  ),
                  DashboardStatsCard(
                    title: "Pending",
                    count: userProvider.pendingUser.toString(),
                    color: Colors.orange,
                    icon: Icons.pending_actions,
                    onTap: () => _navigateToUserTab("", "Pending"),
                  ),
                  DashboardStatsCard(
                    title: "Disabled",
                    count: userProvider.disableUser.toString(),
                    color: Colors.grey,
                    icon: Icons.block,
                    onTap: () => _navigateToUserTab("", "Disabled"),
                  ),
                  DashboardStatsCard(
                    title: "Deleted",
                    count: userProvider.deletedUser.toString(),
                    color: Colors.red,
                    icon: Icons.delete_outline,
                    onTap: () => _navigateToUserTab("", "Deleted"),
                  ),
                ],
              ),

              // Products Section
              DashboardSection(
                title: "Product Overview",
                titleColor: Colors.purple,
                children: [
                  DashboardStatsCard(
                    title: "Total Products",
                    count: userProvider.totalProductCount.toString(),
                    color: Colors.purple,
                    icon: Icons.inventory_2,
                    onTap: () => navigateToProductsScreen(),
                  ),
                  DashboardStatsCard(
                    title: "Category A",
                    count: userProvider.totalProductA.toString(),
                    color: Colors.blue,
                    icon: Icons.category,
                    onTap: () => navigateToProductsScreen(category: "A"),
                  ),
                  DashboardStatsCard(
                    title: "Category B",
                    count: userProvider.totalProductB.toString(),
                    color: Colors.green,
                    icon: Icons.category,
                    onTap: () => navigateToProductsScreen(category: "B"),
                  ),
                  DashboardStatsCard(
                    title: "Category C",
                    count: userProvider.totalProductC.toString(),
                    color: Colors.orange,
                    icon: Icons.category,
                    onTap: () => navigateToProductsScreen(category: "C"),
                  ),
                  DashboardStatsCard(
                    title: "Category D",
                    count: userProvider.totalProductD.toString(),
                    color: Colors.red,
                    icon: Icons.category,
                    onTap: () => navigateToProductsScreen(category: "D"),
                  ),
                  DashboardStatsCard(
                    title: "Category E",
                    count: userProvider.totalProductE.toString(),
                    color: Colors.teal,
                    icon: Icons.category,
                    onTap: () => navigateToProductsScreen(category: "E"),
                  ),
                ],
              ),

              // Reports Section
              DashboardSection(
                title: "Reports",
                titleColor: Colors.redAccent,
                children: [
                  DashboardStatsCard(
                    title: "Total Reports",
                    count: userProvider.totalReport.toString(),
                    color: Colors.redAccent,
                    icon: Icons.report_problem,
                  ),
                ],
              ),

              // User Categories Sections (A, B, Alpha, Beta)
              _buildUserCategorySection(
                "User Category A",
                "A",
                userProvider.totalUserA,
                userProvider.verifiedUserA,
                userProvider.pendingUserA,
                userProvider.disableUserA,
                userProvider.deletedUserA,
                Colors.indigo,
              ),
              _buildUserCategorySection(
                "User Category B",
                "B",
                userProvider.totalUserB,
                userProvider.verifiedUserB,
                userProvider.pendingUserB,
                userProvider.disableUserB,
                userProvider.deletedUserB,
                Colors.teal,
              ),
              _buildUserCategorySection(
                "User Category α",
                "α",
                userProvider.totalUser1,
                userProvider.verifiedUser1,
                userProvider.pendingUser1,
                userProvider.disableUser1,
                userProvider.deletedUser1,
                Colors.deepPurple,
              ),
              _buildUserCategorySection(
                "User Category β",
                "β",
                userProvider.totalUser2,
                userProvider.verifiedUser2,
                userProvider.pendingUser2,
                userProvider.disableUser2,
                userProvider.deletedUser2,
                Colors.deepOrange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCategorySection(
    String title,
    String categoryCode,
    int total,
    int verified,
    int pending,
    int disabled,
    int deleted,
    Color themeColor,
  ) {
    return DashboardSection(
      title: title,
      titleColor: themeColor,
      children: [
        DashboardStatsCard(
          title: "Total",
          count: total.toString(),
          color: themeColor,
          icon: Icons.group,
          onTap: () => _navigateToUserTab(categoryCode, ""),
        ),
        DashboardStatsCard(
          title: "Verified",
          count: verified.toString(),
          color: Colors.green,
          icon: Icons.verified,
        ),
        DashboardStatsCard(
          title: "Pending",
          count: pending.toString(),
          color: Colors.orange,
          icon: Icons.pending,
          onTap: () => _navigateToUserTab(categoryCode, "Pending"),
        ),
        DashboardStatsCard(
          title: "Disabled",
          count: disabled.toString(),
          color: Colors.grey,
          icon: Icons.block,
          onTap: () => _navigateToUserTab(categoryCode, "Disabled"),
        ),
        DashboardStatsCard(
          title: "Deleted",
          count: deleted.toString(),
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _navigateToUserTab(categoryCode, "Deleted"),
        ),
      ],
    );
  }
}

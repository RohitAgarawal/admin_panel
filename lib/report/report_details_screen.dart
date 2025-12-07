import 'package:admin_panel/provider/user_provider/user_provider.dart';
import 'package:admin_panel/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import '../navigation/getX_navigation.dart';
import '../product/product_details_screen/bike/bike_details_screen.dart';
import '../product/product_details_screen/book_sport_hobby/book_sports_hobby_details_screen.dart';
import '../product/product_details_screen/car/car_details_screen.dart';
import '../product/product_details_screen/electronics/electronics_detail_screen.dart';
import '../product/product_details_screen/furniture/furniture_details_screen.dart';
import '../product/product_details_screen/job/job_details_screens.dart';
import '../product/product_details_screen/other/other_details_screen.dart';
import '../product/product_details_screen/pet/pet_details_screen.dart';
import '../product/product_details_screen/property/property_details_screen.dart';
import '../product/product_details_screen/services/services_details_screen.dart';
import '../product/product_details_screen/smart_phone/smart_phone_details_screen.dart';
import '../provider/report_provider/report_provider.dart';
import '../user/user_details_screen.dart';

class ReportDetailsScreen extends StatefulWidget {
  static String routeName = "/report-details-screen";
  const ReportDetailsScreen({super.key});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  String? reportId;
  String? _selectedStatus;
  final TextEditingController _noteController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    reportId = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reportProvider = Provider.of<ReportProvider>(
        context,
        listen: false,
      );
      await reportProvider.reportsDetailsByReportId(reportId!);
      if (reportProvider.selectedReport != null) {
        setState(() {
          _selectedStatus = reportProvider.selectedReport!.status.toLowerCase();
          _noteController.text = reportProvider.selectedReport!.note;
        });
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void openInNewTab(String url) {
    web.window.open(url, '_blank');
  }

  Future<void> _updateStatus(ReportProvider reportProvider) async {
    if (_selectedStatus == null) return;
    setState(() {
      _isUpdating = true;
    });
    bool success = await reportProvider.updateReportStatus(
      reportId!,
      _selectedStatus!,
      _noteController.text,
    );
    setState(() {
      _isUpdating = false;
    });

    if (success) {
      Get.snackbar(
        "Success",
        "Report status updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error",
        "Failed to update report status",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: true,
    );
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Report Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Consumer<ReportProvider>(
            builder: (context, provider, child) {
              final report = provider.selectedReport;
              if (report == null) return SizedBox();
              return IconButton(
                onPressed: () async {
                  await userProvider.userActiveInactive(report.userId);
                  setState(() {
                    report.isActive = !report.isActive;
                  });
                },
                icon: Icon(
                  report.isActive ? Icons.visibility : Icons.visibility_off,
                  color: report.isActive ? Colors.green : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          final report = reportProvider.selectedReport;
          if (reportProvider.isLoading && report == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (report == null) {
            return const Center(child: Text("No report details available."));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main layout: Left (Info) and Right (Details) for large screens if needed,
                    // but keeping it simple column for now as per admin panel usage

                    // Top Section: Image & Basic Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            openInNewTab(
                              'https://api.bhavnika.shop${report.image}',
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://api.bhavnika.shop${report.image}',
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    height: 150,
                                    width: 150,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Model: ${report.modelName.toUpperCase()}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Report ID: ${report.id}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Date: ${DateFormat('d MMM yyyy, hh:mm a').format(DateTime.parse(report.createdAt).toLocal())}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    report.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(report.status),
                                  ),
                                ),
                                child: Text(
                                  report.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(report.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Update Status Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Update Status",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedStatus,
                                    decoration: InputDecoration(
                                      labelText: "Status",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "pending",
                                        child: Text("Pending"),
                                      ),
                                      DropdownMenuItem(
                                        value: "resolve",
                                        child: Text("Resolve"),
                                      ),
                                      DropdownMenuItem(
                                        value: "decline",
                                        child: Text("Decline"),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedStatus = val;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _noteController,
                                    decoration: InputDecoration(
                                      labelText: "Admin Note",
                                      hintText: "Add a note...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: _isUpdating
                                    ? null
                                    : () => _updateStatus(reportProvider),
                                icon: _isUpdating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: const Text("Save Changes"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Details Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Report & Product Info
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "📋 Complaint Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  _buildDetailRow(
                                    "Description",
                                    report.description,
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "📦 Product Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  _buildDetailRow("Title", report.productTitle),
                                  _buildDetailRow(
                                    "Category",
                                    report.productCategory,
                                  ),
                                  _buildDetailRow("Price", report.productPrice),
                                  _buildDetailRow(
                                    "Address",
                                    report.productAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        navigateToProductFormScreen(
                                          report.modelName,
                                          report.productId,
                                        );
                                      },
                                      icon: const Icon(Icons.open_in_new),
                                      label: const Text("View Full Product"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Users Info
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "👤 Reporter Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  _buildDetailRow("Name", report.userName),
                                  _buildDetailRow("Email", report.userEmail),
                                  _buildDetailRow("Phone", report.userPhone),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Get.toNamed(
                                          UserDetailsScreen.routeName,
                                          arguments: report.userId,
                                        );
                                      },
                                      child: const Text("View Profile"),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  const Text(
                                    "👤 Product Owner Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  _buildDetailRow(
                                    "Name",
                                    "${report.productUserFName} ${report.productUserLName}",
                                  ),
                                  _buildDetailRow(
                                    "Email",
                                    report.productUserEmail,
                                  ),
                                  _buildDetailRow(
                                    "Phone",
                                    report.productUserPhone,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Get.toNamed(
                                          UserDetailsScreen.routeName,
                                          arguments: report.productUserId,
                                        );
                                      },
                                      child: const Text("View Profile"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
              if (userProvider.isLoading)
                Container(
                  color: Colors.black12,
                  child: const Center(child: LoadingWidget()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "N/A" : value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolve':
        return Colors.green;
      case 'decline':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  void navigateToProductFormScreen(String modelName, String productId) {
    print(modelName);
    Map<String, dynamic> args = {
      "productId": productId,
      "modelName": modelName,
      "isEdit": false,
    };
    switch (modelName.toLowerCase()) {
      case "bike":
        GetxNavigation.next(BikeDetailsScreen.routeName, arguments: args);
        break;
      case "property":
        GetxNavigation.next(PropertyDetailsScreen.routeName, arguments: args);
        break;
      case "car":
        GetxNavigation.next(CarDetailsScreen.routeName, arguments: args);
        break;
      case "book_sport_hobby":
        GetxNavigation.next(
          BookSportsHobbyDetailsScreen.routeName,
          arguments: args,
        );
        break;
      case "electronic":
        GetxNavigation.next(
          ElectronicsDetailsScreen.routeName,
          arguments: args,
        );
        break;
      case "furniture":
        GetxNavigation.next(FurnitureDetailsScreen.routeName, arguments: args);
        break;
      case "job":
        GetxNavigation.next(JobDetailsScreen.routeName, arguments: args);
        break;
      case "pet":
        GetxNavigation.next(PetDetailsScreen.routeName, arguments: args);
        break;
      case "smart_phone":
        GetxNavigation.next(SmartPhoneDetailsScreen.routeName, arguments: args);
        break;
      case "services":
        GetxNavigation.next(ServicesDetailScreen.routeName, arguments: args);
        break;
      case "other":
        GetxNavigation.next(OtherProductDetails.routeName, arguments: args);
        break;
      default:
        Get.snackbar(
          "Oops!!!!!",
          "Something went wrong while selecting option.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }
}

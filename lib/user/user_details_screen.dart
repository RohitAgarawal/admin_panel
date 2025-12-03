import 'package:admin_panel/provider/product_provider/product_provider.dart';
import 'package:admin_panel/provider/user_provider/user_provider.dart';
import 'package:admin_panel/utils/date_formater.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

class UserDetailsScreen extends StatefulWidget {
  static const routeName = "/user-details-screen";
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  String userId = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      userId = Get.arguments;
      Provider.of<UserProvider>(context, listen: false).clearUserData();
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId);
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).getProductByUserId(userId);
    });
  }

  Future<void> _launchURL(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 900;

          if (isWideScreen) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Profile & Key Info
                Container(
                  width: 380,
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, user, _) =>
                              _buildProfileCard(user),
                        ),
                        const SizedBox(height: 24),
                        Consumer<UserProvider>(
                          builder: (context, user, _) =>
                              _buildContactCard(user),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right Column: Detailed Info & Products
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, user, _) =>
                              _buildStatusSection(user),
                        ),
                        const SizedBox(height: 24),
                        Consumer<UserProvider>(
                          builder: (context, user, _) =>
                              _buildDetailsSection(user),
                        ),
                        const SizedBox(height: 24),
                        Consumer<UserProvider>(
                          builder: (context, user, _) =>
                              _buildAadhaarSection(user),
                        ),
                        const SizedBox(height: 24),
                        Consumer<ProductProvider>(
                          builder: (context, product, _) =>
                              _buildProductsSection(product),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Mobile Layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Consumer<UserProvider>(
                    builder: (context, user, _) => _buildProfileCard(user),
                  ),
                  const SizedBox(height: 16),
                  Consumer<UserProvider>(
                    builder: (context, user, _) => _buildStatusSection(user),
                  ),
                  const SizedBox(height: 16),
                  Consumer<UserProvider>(
                    builder: (context, user, _) => _buildContactCard(user),
                  ),
                  const SizedBox(height: 16),
                  Consumer<UserProvider>(
                    builder: (context, user, _) => _buildDetailsSection(user),
                  ),
                  const SizedBox(height: 16),
                  Consumer<UserProvider>(
                    builder: (context, user, _) => _buildAadhaarSection(user),
                  ),
                  const SizedBox(height: 16),
                  Consumer<ProductProvider>(
                    builder: (context, product, _) =>
                        _buildProductsSection(product),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileCard(UserProvider user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.green.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  if (user.userProfileImage.isNotEmpty) {
                    final fullUrl = user.userProfileImage.startsWith('http')
                        ? user.userProfileImage
                        : 'https://api.bhavnika.shop${user.userProfileImage}';
                    _launchURL(fullUrl);
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: user.userProfileImage.isNotEmpty
                      ? NetworkImage(
                          user.userProfileImage.startsWith('http')
                              ? user.userProfileImage
                              : 'https://api.bhavnika.shop${user.userProfileImage}',
                        )
                      : null,
                  child: user.userProfileImage.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${user.userFName} ${user.userLName}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Text(
                "Category: ${user.userCategory}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              "Joined",
              DateFormater.formatDate(user.registrationDate),
              isDark: true,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.work_outline,
              "Occupation",
              user.userOccupationId,
              isDark: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(UserProvider user) {
    return Card(
      elevation: 4,
      shadowColor: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_phone_rounded, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                const Text(
                  "Contact Info",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildContactItem(
              Icons.email_outlined,
              "Email",
              user.userEmail,
              Colors.blue,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _buildContactItem(
              Icons.phone_outlined,
              "Phone",
              user.userPhone,
              Colors.green,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _buildContactItem(
              Icons.location_on_outlined,
              "Address",
              "${user.userStreet1}, ${user.userStreet2}\n${user.userArea}, ${user.userDistrict}\n${user.userState} - ${user.userPinCode}",
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(UserProvider user) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatusChip("Active", user.isActive, Colors.green),
        _buildStatusChip("Blocked", user.isBlocked, Colors.red),
        _buildStatusChip("Verified", user.isVerified, Colors.blue),
        if (user.userCategory == 'A')
          _buildStatusChip("PIN Verified", user.isPinVerified, Colors.purple)
        else
          _buildStatusChip("OTP Verified", user.isOtpVerified, Colors.orange),
      ],
    );
  }

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: isActive ? Colors.white : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(UserProvider user) {
    return Card(
      elevation: 3,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: Colors.purple.shade700,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Personal Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 40,
              runSpacing: 24,
              children: [
                _buildDetailItem("First Name", user.userFName),
                _buildDetailItem("Middle Name", user.userMName),
                _buildDetailItem("Last Name", user.userLName),
                _buildDetailItem("Date of Birth", user.userDOB),
                _buildDetailItem("Gender", user.userGender),
                _buildDetailItem("UID Number", user.uIdNumber),
                if (user.userCategory == "A")
                  _buildDetailItem("Assigned PIN", user.userAssignPin),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAadhaarSection(UserProvider user) {
    return Card(
      elevation: 3,
      shadowColor: Colors.teal.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text(
            "Aadhaar Verification",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Aadhaar Number: ${user.userAadhaarNumber}",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fingerprint, color: Colors.teal.shade700),
          ),
          childrenPadding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildIdImage("Front Side", user.userAadhaarFront),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildIdImage("Back Side", user.userAadhaarBack),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdImage(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: url.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    final fullUrl = url.startsWith('http')
                        ? url
                        : 'https://api.bhavnika.shop$url';
                    _launchURL(fullUrl);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      url.startsWith('http')
                          ? url
                          : 'https://api.bhavnika.shop$url',
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text("No Image", style: TextStyle(color: Colors.grey)),
                ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(ProductProvider productProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Products (${productProvider.filteredProducts.length})",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: productProvider.filteredProducts.length,
              itemBuilder: (context, index) {
                final product = productProvider.filteredProducts[index];
                return _buildProductCard(product);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(dynamic product) {
    final imageUrl = product.images.isNotEmpty
        ? 'https://api.bhavnika.shop${product.images.first}'
        : '';

    return InkWell(
      onTap: () => navigateToProductFormScreen(product.modelName, product.id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey.shade100,
                ),
                child: imageUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.adTitle.last.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "₹ ${product.price}",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.modelName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isDark = false,
  }) {
    Color iconColor = isDark ? Colors.white70 : Colors.grey.shade500;
    Color labelColor = isDark ? Colors.white70 : Colors.grey.shade500;
    Color valueColor = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
            Text(
              value.isEmpty ? "N/A" : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: accentColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 4),
              SelectableText(
                value.isEmpty ? "N/A" : value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          SelectableText(
            value.isEmpty ? "N/A" : value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  void navigateToProductFormScreen(String modelName, String productId) {
    print(modelName);
    Map<String, String> args = {"productId": productId, "modelName": modelName};
    switch (modelName.toLowerCase()) {
      case "bike":
        {
          GetxNavigation.next(BikeDetailsScreen.routeName, arguments: args);
          break;
        }
      case "property":
        {
          GetxNavigation.next(PropertyDetailsScreen.routeName, arguments: args);
          // GetxNavigation.next(Property.routeName,arguments: productSubType);
          break;
        }
      case "car":
        {
          GetxNavigation.next(CarDetailsScreen.routeName, arguments: args);
          break;
        }
      case "book_sport_hobby":
        {
          GetxNavigation.next(
            BookSportsHobbyDetailsScreen.routeName,
            arguments: args,
          );
          break;
        }
      case "electronic":
        {
          GetxNavigation.next(
            ElectronicsDetailsScreen.routeName,
            arguments: args,
          );
          break;
        }
      case "furniture":
        {
          GetxNavigation.next(
            FurnitureDetailsScreen.routeName,
            arguments: args,
          );
          break;
        }
      case "job":
        {
          GetxNavigation.next(JobDetailsScreen.routeName, arguments: args);
          break;
        }
      case "pet":
        {
          GetxNavigation.next(PetDetailsScreen.routeName, arguments: args);
          break;
        }
      case "smart_phone":
        {
          GetxNavigation.next(
            SmartPhoneDetailsScreen.routeName,
            arguments: args,
          );
          // GetxNavigation.next(SmartPhone.routeName,arguments: productSubType);
          break;
        }
      case "services":
        {
          GetxNavigation.next(ServicesDetailScreen.routeName, arguments: args);
          break;
        }
      case "other":
        {
          GetxNavigation.next(OtherProductDetails.routeName, arguments: args);
          // GetxNavigation.next(OtherScreen.routeName,arguments: productSubType);
          break;
        }
      default:
        {
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
}

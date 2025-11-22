import 'package:admin_panel/provider/product_provider/product_provider.dart';
import 'package:admin_panel/provider/user_provider/user_provider.dart';
import 'package:admin_panel/utils/date_formater.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

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
  bool _showAadhaarDetails = false; // At the top of your widget state

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      userId = Get.arguments;
      Provider.of<UserProvider>(context, listen: false).clearUserData();
      Provider.of<UserProvider>(context, listen: false).fetchUserData(userId);
      Provider.of<ProductProvider>(context, listen: false).getProductByUserId(userId);
    });
  }



  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);
    ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("User Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Text("User Profile Image", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: userProvider.userProfileImage.isNotEmpty
                          ? NetworkImage(
                        userProvider.userProfileImage.startsWith('http')
                            ? userProvider.userProfileImage
                            : 'https://api.bhavnika.shop${userProvider.userProfileImage}',
                      )
                          : null,
                      child: userProvider.userProfileImage.isEmpty
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Aadhaar Proof", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAadhaarDetails = !_showAadhaarDetails;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.article_outlined),
                              const SizedBox(width: 10),
                              Text(_showAadhaarDetails ? "Hide Aadhaar Details" : "View Aadhaar Proof"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_showAadhaarDetails) ...[
                        Text("Aadhaar Number: ${userProvider.userAadhaarNumber}"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade300,
                                ),
                                child: userProvider.userAadhaarFront.isNotEmpty
                                    ? Image.network(
                                  userProvider.userAadhaarFront.startsWith('http')
                                      ? userProvider.userAadhaarFront
                                      : 'https://api.bhavnika.shop${userProvider.userAadhaarFront}',
                                  fit: BoxFit.contain,
                                )
                                    : const Center(child: Text("No Front Image")),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade300,
                                ),
                                child: userProvider.userAadhaarBack.isNotEmpty
                                    ? Image.network(
                                  userProvider.userAadhaarBack.startsWith('http')
                                      ? userProvider.userAadhaarBack
                                      : 'https://api.bhavnika.shop${userProvider.userAadhaarBack}',
                                  fit: BoxFit.contain,
                                )
                                    : const Center(child: Text("No Back Image")),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(title: "First Name", value: userProvider.userFName),
                      InfoRow(title: "Middle Name", value: userProvider.userMName),
                      InfoRow(title: "Last Name", value: userProvider.userLName),
                      InfoRow(title: "DOB", value: userProvider.userDOB),
                      InfoRow(title: "Email", value: userProvider.userEmail),
                      InfoRow(title: "Phone", value: userProvider.userPhone),
                      InfoRow(title: "State", value: userProvider.userState),
                      InfoRow(title: "District", value: userProvider.userDistrict),
                      InfoRow(title: "Area", value: userProvider.userArea),
                      InfoRow(title: "Street1", value: userProvider.userStreet1),
                      InfoRow(title: "Street2", value: userProvider.userStreet2),

                      InfoRow(title: "PinCode", value: userProvider.userPinCode),
                      InfoRow(title: "Occupation", value: userProvider.userOccupationId),
                     // InfoRow(title: "Role", value: userProvider.userRole),
                      InfoRow(title: "Category", value: userProvider.userCategory),
                      //InfoRow(title: "Verified", value: userProvider.isVerified ? "Yes" : "No"),
                      InfoRow(title: "Blocked", value: userProvider.isBlocked ? "Yes" : "No"),
                      InfoRow(title: "Aadhaar Number", value: userProvider.userAadhaarNumber ),
                      InfoRow(title: "UId Number", value: userProvider.uIdNumber ),
                      if(userProvider.userCategory == "A")...[
                        InfoRow(title: "Pin Verified", value: userProvider.isPinVerified ? "Yes" : "No"),
                      ] else...[
                        InfoRow(title: "OTP Verified", value: userProvider.isOtpVerified ? "Yes" : "No"),
                      ],


                      if(userProvider.userCategory == "A")...[InfoRow(title: "User Pin", value: userProvider.userAssignPin)]else...[
                      ],
                      InfoRow(title: "Registration date", value:DateFormater.formatDate(userProvider.registrationDate)  ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: Alignment.centerRight,
                    child: Text("Total User added Product:-${productProvider.filteredProducts.length}")),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  int crossAxisCount = (width / 280).floor();
                  crossAxisCount = crossAxisCount < 2 ? 2 : crossAxisCount;

                  return GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320, // Maximum width per item
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.0, // You can adjust height ratio
                    ),
                    itemCount: productProvider.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.filteredProducts[index];
                      final title = product.adTitle.last.toString();
                      final price = product.price;
                      final description = product.description.last.toString();
                    //  final area = product.address1.last.toString();
                      final imageUrl =
                      product.images.isNotEmpty
                          ? 'https://api.bhavnika.shop${product.images.first}'
                          : '';
                      return GestureDetector(
                        onTap: () {
                          navigateToProductFormScreen(
                            product.modelName,
                            product.id,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.shade700,
                              width: 1.5,
                            )

                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          imageUrl,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          if(price.isNotEmpty)
                                            Text(
                                              '₹ $price',
                                              style: TextStyle(
                                                color: Colors.green.shade800,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          SizedBox(height: 4),
                                          Text(
                                            title,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Expanded(
                                            child: Text(
                                              description,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6),
                              // Align(
                              //   alignment: Alignment.centerLeft,
                              //   child: Text(
                              //     area,
                              //     style: TextStyle(color: Colors.grey[600]),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

            ],
          ),
        ),
      )

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

class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: SelectableText("$title:", style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: SelectableText(value)),
        ],
      ),
    );
  }
}

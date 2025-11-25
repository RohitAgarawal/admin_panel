import 'package:admin_panel/model/product_model/product.dart';
import 'package:admin_panel/product/components/filter_sheet.dart';
import 'package:admin_panel/product/components/product_card.dart';
import 'package:admin_panel/product/components/product_filter_bar.dart';
import 'package:admin_panel/product/product_details_screen/bike/bike_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/book_sport_hobby/book_sports_hobby_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/car/car_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/electronics/electronics_detail_screen.dart';
import 'package:admin_panel/product/product_details_screen/furniture/furniture_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/job/job_details_screens.dart';
import 'package:admin_panel/product/product_details_screen/other/other_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/pet/pet_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/property/property_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/services/services_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/smart_phone/smart_phone_details_screen.dart';
import 'package:admin_panel/provider/product_provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../navigation/getX_navigation.dart';
import '../network_connection/apis.dart';

class AllProductGet extends StatefulWidget {
  static const routeName = "/all-product-get";

  const AllProductGet({super.key});

  @override
  State<AllProductGet> createState() => _AllProductGetState();
}

class _AllProductGetState extends State<AllProductGet>
    with SingleTickerProviderStateMixin {
  String baseUrl = Apis.BASE_URL_IMAGE;
  String selectedCategory = "";
  int selectedProductTypeIndex = 0;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Advanced Filters
  String _sortBy = 'newest'; // newest, oldest, price_asc, price_desc
  RangeValues _priceRange = const RangeValues(0, 1000000000);
  bool _isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Get the selected category from the provider
    selectedCategory = productProvider.getSelectedCategory;

    // Initial Fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    productProvider.getProductType().then((_) {
      if (productProvider.products.isNotEmpty) {
        // If we have a selected category from provider, use it
        if (selectedCategory.isNotEmpty) {
          final productTypeId =
              productProvider.products[selectedProductTypeIndex].id;
          productProvider.fetchProducts(
            productTypeId,
            category: selectedCategory,
          );
        } else {
          final productTypeId =
              productProvider.products[selectedProductTypeIndex].id;
          productProvider.fetchProducts(productTypeId);
        }
      }
    });
  }

  void _onProductTypeSelected(int index) {
    setState(() {
      selectedProductTypeIndex = index;
      selectedCategory = ""; // Reset sub-category when switching types
      _sortBy = 'newest'; // Reset sort
      _isFilterApplied = false; // Reset filter flag
      searchController.clear();
      searchQuery = '';
    });
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final productTypeId = productProvider.products[index].id;
    productProvider.fetchProducts(productTypeId);
  }

  void _onCategorySelected(String category) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final productTypeId = productProvider.products[selectedProductTypeIndex].id;

    if (selectedCategory == category) {
      // Deselect
      setState(() {
        selectedCategory = "";
      });
      productProvider.fetchProducts(productTypeId);
    } else {
      // Select
      setState(() {
        selectedCategory = category;
      });
      productProvider.fetchProducts(productTypeId, category: category);
    }
  }

  List<ProductModel> _getProcessedProducts(List<ProductModel> products) {
    List<ProductModel> processed = List.from(products);

    // 1. Search Filter (Client-side if needed, though provider has searchProduct)
    // The provider's searchProduct hits the API.
    // If we want to filter the CURRENT list, we can do it here.
    // But usually search replaces the list.
    // Let's rely on the provider's list which should already be filtered by search if the user used the search bar.
    // However, the search bar in the UI calls `productProvider.searchProduct`.
    // So `products` here is already the result of that.

    // 2. Price Range Filter
    if (_isFilterApplied) {
      processed = processed.where((p) {
        if (p.price.isEmpty)
          return true; // Keep items with no price? Or hide? Let's keep.
        String priceStr = p.price.last.toString();
        // Clean price string
        priceStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
        double? price = double.tryParse(priceStr);
        if (price == null) return true;
        return price >= _priceRange.start && price <= _priceRange.end;
      }).toList();
    }

    // 3. Sorting
    switch (_sortBy) {
      case 'price_asc':
        processed.sort((a, b) {
          double priceA = _parsePrice(a);
          double priceB = _parsePrice(b);
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_desc':
        processed.sort((a, b) {
          double priceA = _parsePrice(a);
          double priceB = _parsePrice(b);
          return priceB.compareTo(priceA);
        });
        break;
      case 'oldest':
        processed = processed.reversed.toList();
        break;
      case 'newest':
      default:
        // Default order (usually newest from API)
        break;
    }

    return processed;
  }

  double _parsePrice(ProductModel p) {
    if (p.price.isEmpty) return 0;
    String priceStr = p.price.last.toString();
    priceStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(priceStr) ?? 0;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(
        currentSort: _sortBy,
        currentPriceRange: _priceRange,
        onSortChanged: (val) => setState(() => _sortBy = val),
        onPriceRangeChanged: (val) => setState(() => _priceRange = val),
        onApply: () {
          setState(() {
            _isFilterApplied = true;
          }); // Trigger rebuild to apply filters
        },
        onReset: () {
          setState(() {
            _sortBy = 'newest';
            _priceRange = const RangeValues(0, 1000000000);
            _isFilterApplied = false;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = _getProcessedProducts(productProvider.filteredProducts);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Products",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your inventory",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  // Search and Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                              if (searchQuery.isNotEmpty) {
                                productProvider.searchProduct(
                                  searchQuery,
                                  productProvider.getSelectedCategory,
                                  productProvider.modelName,
                                );
                              } else {
                                // Reload current category
                                _onProductTypeSelected(
                                  selectedProductTypeIndex,
                                );
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Search products...",
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _showFilterSheet,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Filter Bar
          SliverToBoxAdapter(
            child: ProductFilterBar(
              productTypes: productProvider.products,
              selectedTypeIndex: selectedProductTypeIndex,
              selectedCategory: selectedCategory,
              onTypeSelected: _onProductTypeSelected,
              onCategorySelected: _onCategorySelected,
              getCategoryCounts: (index) {
                // This is a bit tricky as the signature expects int->Record
                // But we are not using this callback in the new implementation of FilterBar
                // I simplified the FilterBar to not need this callback for rendering the A-E list directly.
                // Wait, I need to check my FilterBar implementation.
                // In FilterBar I commented out the usage of counts for A-E.
                // So passing a dummy function is fine or I should have removed it.
                // Let's just pass the provider function.
                return productProvider.countByProductTypeId(index);
              },
            ),
          ),

          const SliverPadding(padding: EdgeInsets.all(12)),

          // Product Grid
          if (productProvider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            )
          else if (products.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No products found",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7, // Adjusted for better fit
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => navigateToProductFormScreen(
                      product.modelName,
                      product.id,
                    ),
                  );
                }, childCount: products.length),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  void navigateToProductFormScreen(String modelName, String productId) {
    Map<String, dynamic> args = {
      "productId": productId,
      "modelName": modelName,
      "isEdit": true,
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

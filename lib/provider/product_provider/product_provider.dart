import 'dart:convert';

import 'package:admin_panel/local_Storage/admin_shredPreferences.dart';
import 'package:admin_panel/model/product_model/product.dart';
import 'package:admin_panel/model/product_model/product_type_model.dart';
import 'package:admin_panel/network_connection/apis.dart';
import 'package:admin_panel/utils/toast_message/toast_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../model/product_model/bike_model.dart';
import '../../model/product_model/book_model.dart';
import '../../model/product_model/car_model.dart';
import '../../model/product_model/electronics_model.dart';
import '../../model/product_model/furniture_model.dart';
import '../../model/product_model/job_model.dart';
import '../../model/product_model/other_model.dart';
import '../../model/product_model/pet_moel.dart';
import '../../model/product_model/property_model.dart';
import '../../model/product_model/services_model.dart';
import '../../model/product_model/smart_phone_model.dart';
import '../../navigation/getX_navigation.dart';

class ProductProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get filteredProducts => _filteredProducts;
  final String _id = '';
  final String _name = '';
  final String _modelName = '';

  String get id => _id;
  String get name => _name;
  String get modelName => _modelName;

  List<ProductTypeModel> products = [];
  List<ProductTypeModel> get productList => products;

  final List<ProductModel> _productModel = [];
  List<ProductModel> get productModel => _productModel;

  List<CarModel> _car = [];
  List<BikeModel> _bike = [];
  List<CarModel> get carList => _car;
  List<BikeModel> get bikeList => _bike;
  List<BookModel> _book = [];
  List<BookModel> get bookList => _book;
  List<ElectronicsModel> _electronics = [];
  List<ElectronicsModel> get electronicsList => _electronics;
  List<FurnitureModel> _furniture = [];
  List<FurnitureModel> get furnitureList => _furniture;
  List<JobModel> _job = [];
  List<JobModel> get jobList => _job;
  List<SmartPhoneModel> _smartPhone = [];
  List<SmartPhoneModel> get smartPhoneList => _smartPhone;
  List<OtherModel> _other = [];
  List<OtherModel> get otherList => _other;
  List<PetModel> _pet = [];
  List<PetModel> get petList => _pet;
  List<PropertyModel> _property = [];
  List<PropertyModel> get propertyList => _property;
  List<ServicesModel> _services = [];
  List<ServicesModel> get servicesList => _services;
  String _selectedCategory = "";
  String get getSelectedCategory => _selectedCategory;

  void setSelectedCategory(String value) {
    if (value == _selectedCategory) {
      _selectedCategory = "";
      notifyListeners();
      return; // No change, so do nothing
    }
    _selectedCategory = value;
    notifyListeners();
  }

  int countByCategory(String category) {
    return _allProducts.where((p) => p.category == category).length;
  }

  ({int A, int B, int C, int D, int E}) countByProductTypeId(int index) {
    CategoryCount categoryCount = products[index].categoryCounts;
    int countA = categoryCount.countForA;
    int countB = categoryCount.countForB;
    int countC = categoryCount.countForC;
    int countD = categoryCount.countForD;
    int countE = categoryCount.countForE;
    return (A: countA, B: countB, C: countC, D: countD, E: countE);
  }

  List<String> nameList = [];
  void setNames(List<ProductTypeModel> names) {
    nameList = _name as List<String>;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setProducts(List<ProductModel> products) {
    _allProducts = products;
    _filteredProducts = products;
    notifyListeners();
  }

  Future<void> getProductType() async {
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('GET', Uri.parse(Apis.PRODUCT_TYPE));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String responseBody = await response.stream.bytesToString();
    print(responseBody);
    Map<String, dynamic> resJson = json.decode(responseBody);
    List<ProductTypeModel> tempList = [];
    if (response.statusCode == 200) {
      for (var item in resJson['data']) {
        tempList.add(ProductTypeModel.fromJson(item));
      }
      products = tempList;
      if (products.isNotEmpty) {
        // Preserve category filter when fetching products
        if (_selectedCategory.isNotEmpty) {
          fetchProducts(products[0].id, category: _selectedCategory);
        } else {
          fetchProducts(products[0].id);
        }
      }
      notifyListeners();
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      AdminSharedPreferences().logout(message: "Session Expired");
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> fetchProducts(
    String productTypeId, {
    String category = "",
  }) async {
    final url = Uri.parse(
      '${Apis.BASE_URL}/admin/get_product_with_type?productTypeId=$productTypeId&category=$category',
    );

    try {
      String token = await AdminSharedPreferences().getAuthToken();

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var request = http.Request('GET', url);
      request.headers.addAll(headers);

      http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Response Data: $responseData');

        if (responseData.containsKey('products')) {
          List<ProductModel> tempProducts = [];
          responseData['products'].forEach((modelName, productCategoryData) {
            if (productCategoryData is Map &&
                productCategoryData.containsKey('items')) {
              List productList = productCategoryData['items'];
              tempProducts.addAll(
                productList
                    .map((item) {
                      return getProductByModelName(modelName, item);
                    })
                    .whereType<ProductModel>()
                    .toList(),
              );
            }
          });

          setProducts(tempProducts);
          print("✅ Loaded Products: $tempProducts");

          if (category.isNotEmpty) {
            _filteredProducts = _allProducts
                .where((p) => p.category == category)
                .toList();
          } else {
            _filteredProducts = List.from(_allProducts);
          }

          notifyListeners();
        } else {
          print('⚠️ Error: API response format is incorrect.');
          setLoading(false);
        }
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print('❌ Failed to load products. Status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception('Failed to load products');
      }
    } catch (e, stackTrace) {
      print("❌ Error: $e");
      print("📍 StackTrace: $stackTrace");
    }
  }

  // Future<void> fetchProducts(String productTypeId, {String category=""}) async {
  //   final url = Uri.parse('https://api.bhavnika.shop/api/admin/get_product_with_type?productTypeId=$productTypeId&category=$category');
  //
  //   try {
  //     String token = await AdminSharedPreferences().getAuthToken();
  //     var headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization' : 'Bearer $token'
  //     };
  //     var request = http.Request('GET', url);
  //     request.headers.addAll(headers);
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       print('Response Data: $responseData');
  //       final jsonData = responseData;
  //       if (jsonData.containsKey('products')) {
  //         List<ProductModel> tempProducts = [];
  //         jsonData['products'].forEach((modelName, productCategoryData) {
  //           if (productCategoryData is Map && productCategoryData.containsKey('items')) {
  //             List productList = productCategoryData['items'];
  //             tempProducts.addAll(productList.map((item) {
  //               return getProductByModelName(modelName, item);
  //             }).whereType<ProductModel>().toList());
  //           }
  //         });
  //         setProducts(tempProducts); // ✅ set products and notify UI
  //         print("Loaded Products: $tempProducts");
  //       } else {
  //         print('Error: API response format is incorrect.');
  //         setLoading(false);
  //       }
  //       if (category.isNotEmpty) {
  //           _filteredProducts = _allProducts.where((p) => p.category == category).toList();
  //         } else {
  //           _filteredProducts = List.from(_allProducts);
  //         }
  //       // Notify listeners to update the UI
  //       notifyListeners();
  //     } else {
  //       throw Exception('Failed to load products');
  //     }
  //   } catch (e, stackTrace) {
  //     print("❌ Error: $e");
  //     print("📍 StackTrace: $stackTrace");
  //   }
  // }

  ProductModel getProductByModelName(
    String modelName,
    Map<String, dynamic> item,
  ) {
    if (modelName == "Bike") {
      return BikeModel.fromJson(item);
    } else if (modelName == "Car") {
      return CarModel.fromJson(item);
    } else if (modelName == "book_sport_hobby") {
      return BookModel.fromJson(item);
    } else if (modelName == "electronic") {
      return ElectronicsModel.fromJson(item);
    } else if (modelName == "furniture") {
      return FurnitureModel.fromJson(item);
    } else if (modelName == "Job") {
      return JobModel.fromJson(item);
    } else if (modelName == "pet") {
      return PetModel.fromJson(item);
    } else if (modelName == "smart_phone") {
      return SmartPhoneModel.fromJson(item);
    } else if (modelName == "services") {
      return ServicesModel.fromJson(item);
    } else if (modelName == "other") {
      return OtherModel.fromJson(item);
    } else if (modelName == "property") {
      return PropertyModel.fromJson(item);
    } else {
      throw Exception('Unknown model name: $modelName');
    }
  }

  Future<void> fetchProductDetails(String productId, String modelName) async {
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      print(Apis.GET_PRODUCT_BY_ID(productId, modelName));

      var url = Uri.parse(Apis.GET_PRODUCT_BY_ID(productId, modelName));

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var request = http.Request('GET', url);
      request.headers.addAll(headers);

      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);

      print("Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final productData = data['product'];
        print(productData['productType']);
        String category = productData['productType']['modelName'];

        if (category == "Bike") {
          _bike = [];
          _bike.add(BikeModel.fromJson(productData));
        } else if (category == "Car") {
          _car = [];
          _car.add(CarModel.fromJson(productData));
          print(productData);
        } else if (category == "book_sport_hobby") {
          _book = [];
          _book.add(BookModel.fromJson(productData));
        } else if (category == "electronic") {
          _electronics = [];
          _electronics.add(ElectronicsModel.fromJson(productData));
        } else if (category == "furniture") {
          _furniture = [];
          _furniture.add(FurnitureModel.fromJson(productData));
        } else if (category == "Job") {
          _job = [];
          _job.add(JobModel.fromJson(productData));
        } else if (category == "pet") {
          _pet = [];
          _pet.add(PetModel.fromJson(productData));
        } else if (category == "smart_phone") {
          _smartPhone = [];
          _smartPhone.add(SmartPhoneModel.fromJson(productData));
        } else if (category == "services") {
          _services = [];
          _services.add(ServicesModel.fromJson(productData));
        } else if (category == "other") {
          _other = [];
          _other.add(OtherModel.fromJson(productData));
        } else if (category == "property") {
          _property = [];
          _property.add(PropertyModel.fromJson(productData));
        }
        notifyListeners();
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print('Failed to load product: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching product: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateProduct(Map<String, dynamic> body) async {
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request('PUT', Uri.parse(Apis.UPDATE_PRODUCT));
    request.body = json.encode(body);
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    Map<String, dynamic> jsonResponse = json.decode(res);
    if (response.statusCode == 200) {
      final productData = jsonResponse['product'];
      print(productData['productType']);
      String category = productData['productType']['modelName'];

      if (category == "Bike") {
        _bike = [];
        _bike.add(BikeModel.fromJson(productData));
      } else if (category == "Car") {
        _car = [];
        _car.add(CarModel.fromJson(productData));
        print(productData);
      } else if (category == "book_sport_hobby") {
        _book = [];
        _book.add(BookModel.fromJson(productData));
      } else if (category == "electronic") {
        _electronics = [];
        _electronics.add(ElectronicsModel.fromJson(productData));
      } else if (category == "furniture") {
        _furniture = [];
        _furniture.add(FurnitureModel.fromJson(productData));
      } else if (category == "Job") {
        _job = [];
        _job.add(JobModel.fromJson(productData));
      } else if (category == "pet") {
        _pet = [];
        _pet.add(PetModel.fromJson(productData));
      } else if (category == "smart_phone") {
        _smartPhone = [];
        _smartPhone.add(SmartPhoneModel.fromJson(productData));
      } else if (category == "services") {
        _services = [];
        _services.add(ServicesModel.fromJson(productData));
      } else if (category == "other") {
        _other = [];
        _other.add(OtherModel.fromJson(productData));
      } else if (category == "property") {
        _property = [];
        _property.add(PropertyModel.fromJson(productData));
      }
      notifyListeners();
      print('Product updated successfully');
      print(jsonResponse);
      GetxNavigation.goBack();
      ToastMessage.success("Success", "Product updated successfully");

      print(response.reasonPhrase);
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      AdminSharedPreferences().logout(message: "Session Expired");
    } else {
      print('Failed to update product');
      ToastMessage.error("Error", "Failed to update product");
      print(response.reasonPhrase);
    }
  }

  Future<void> deleteProduct(String productId, String productType) async {
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'DELETE',
        Uri.parse(
          '${Apis.BASE_URL}/admin/delete_product_by_admin?productId=$productId&productType=$productType',
        ),
      );
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      if (response.statusCode == 200) {
        ToastMessage.success(
          "Deleted",
          jsonResponse['message'] ?? "Product deleted successfully",
        );
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        ToastMessage.error(
          "Error",
          jsonResponse['message'] ?? "Failed to delete product",
        );
      }
    } catch (e) {
      // ✅ Catch any unexpected errors
      ToastMessage.error("Error", "Something went wrong: $e");
      print("❌ Exception in deleteProduct: $e");
    }
  }

  Future<void> deleteProductImage(Map<String, dynamic> body) async {
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request(
      'DELETE',
      Uri.parse(Apis.PRODUCT_IMAGE_DELETE_BY_USER),
    );
    request.body = json.encode(body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      fetchProductDetails(body['productId'], body['modelName']);
      // ProductProvider productProvider = Provider.of<ProductProvider>(Get.context!, listen:false);
      // productProvider.addUserProduct();
      notifyListeners();
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      AdminSharedPreferences().logout(message: "Session Expired");
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> product_active_inactive(Map<String, dynamic> body) async {
    String token = await AdminSharedPreferences().getAuthToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request(
      'POST',
      Uri.parse('${Apis.BASE_URL}/products/product-active-inactive'),
    );
    request.body = json.encode(body);
    request.headers.addAll(headers);
    print(body);
    http.StreamedResponse response = await request.send();
    String res = await response.stream.bytesToString();
    Map<String, dynamic> jsonResponse = json.decode(res);
    print(jsonResponse);
    if (response.statusCode == 200) {
      final productData = jsonResponse['product'];
      print(productData['productType']);
      String category = productData['productType']['modelName'];

      if (category == "Bike") {
        _bike = [];
        _bike.add(BikeModel.fromJson(productData));
      } else if (category == "Car") {
        _car = [];
        _car.add(CarModel.fromJson(productData));
        print(productData);
      } else if (category == "book_sport_hobby") {
        _book = [];
        _book.add(BookModel.fromJson(productData));
      } else if (category == "electronic") {
        _electronics = [];
        _electronics.add(ElectronicsModel.fromJson(productData));
      } else if (category == "furniture") {
        _furniture = [];
        _furniture.add(FurnitureModel.fromJson(productData));
      } else if (category == "Job") {
        _job = [];
        _job.add(JobModel.fromJson(productData));
      } else if (category == "pet") {
        _pet = [];
        _pet.add(PetModel.fromJson(productData));
      } else if (category == "smart_phone") {
        _smartPhone = [];
        _smartPhone.add(SmartPhoneModel.fromJson(productData));
      } else if (category == "services") {
        _services = [];
        _services.add(ServicesModel.fromJson(productData));
      } else if (category == "other") {
        _other = [];
        _other.add(OtherModel.fromJson(productData));
      } else if (category == "property") {
        _property = [];
        _property.add(PropertyModel.fromJson(productData));
      }
      ToastMessage.success("Success", "Product active/inactive successfully");
      notifyListeners();
    } else if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      AdminSharedPreferences().logout(message: "Session Expired");
    } else {
      ToastMessage.error("Error", "Failed to active/inactive product");
      print(response.reasonPhrase);
    }
  }

  Future<void> getProductByUserId(String userId) async {
    //setLoading(true);
    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var request = http.Request(
        'GET',
        Uri.parse(
          '${Apis.BASE_URL}/admin/get-product-by-userId?userId=$userId',
        ),
      );
      print("Url:---$request");
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      String res = await response.stream.bytesToString();
      Map<String, dynamic> resJson = jsonDecode(res);
      print(resJson);
      if (response.statusCode == 200) {
        List<ProductModel> tempProducts = [];
        print(">>>>>>>>>>>>>>>");
        if (resJson.containsKey('products')) {
          for (var item in resJson['products']) {
            // Skip deleted items
            if (item['isDeleted'] == true) continue;

            String? modelName = item['productType']?['modelName'];
            ProductModel? product;

            if (modelName == "Bike") {
              product = BikeModel.fromJson(item);
            } else if (modelName == "Car") {
              product = CarModel.fromJson(item);
            } else if (modelName == "book_sport_hobby") {
              product = BookModel.fromJson(item);
            } else if (modelName == "electronic") {
              product = ElectronicsModel.fromJson(item);
            } else if (modelName == "furniture") {
              product = FurnitureModel.fromJson(item);
            } else if (modelName == "Job") {
              product = JobModel.fromJson(item);
            } else if (modelName == "pet") {
              product = PetModel.fromJson(item);
            } else if (modelName == "smart_phone") {
              product = SmartPhoneModel.fromJson(item);
            } else if (modelName == "services") {
              product = ServicesModel.fromJson(item);
            } else if (modelName == "other") {
              product = OtherModel.fromJson(item);
            } else if (modelName == "property") {
              product = PropertyModel.fromJson(item);
            }

            if (product != null) {
              print("Parsed Product: ${product.productName}");
              tempProducts.add(product);
            }
          }
          setProducts(tempProducts);
          notifyListeners(); // ✅ Your method to update UI
        } else {
          print('Error: "products" key missing in response.');
        }
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      setLoading(false); // Reset loading state
    }
  }

  //search product but does not work properly
  Future<void> searchProduct(
    String searchQuery,
    String selectedCategory,
    String modelName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      String token = await AdminSharedPreferences().getAuthToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final request = http.Request(
        'GET',
        Uri.parse(
          '${Apis.BASE_URL}/products/get?query=$searchQuery&categories=$selectedCategory&modelName=$modelName',
        ),
      );
      request.headers.addAll(headers);

      final response = await request.send();
      final res = await response.stream.bytesToString();
      final Map<String, dynamic> resJson = jsonDecode(res);
      print("-=-=-=-=-=--=-=-=-");
      print(resJson);
      print("-=-=-=-=-=--=-=-=-");
      if (response.statusCode == 200) {
        List<ProductModel> tempList = [];
        resJson['data'].forEach((product) {
          tempList.add(
            createProductFromJson(
              product['productType']['modelName'].toString().toLowerCase(),
              product,
            ),
          );
        });

        _filteredProducts = tempList;
      } else if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 423) {
        AdminSharedPreferences().logout(message: "Session Expired");
      } else {
        print("❌ Error: ${response.reasonPhrase} (${response.statusCode})");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  ProductModel createProductFromJson(
    String category,
    Map<String, dynamic> json,
  ) {
    print(category);
    switch (category) {
      case 'car':
        return CarModel.fromJson(json);
      case 'bike':
        return BikeModel.fromJson(json);
      case 'electronic':
        return ElectronicsModel.fromJson(json);
      case 'furniture':
        return FurnitureModel.fromJson(json);
      case 'other':
        return OtherModel.fromJson(json);
      case 'property':
        return PropertyModel.fromJson(json);
      case 'book_sport_hobby':
        return BookModel.fromJson(json);
      case 'pet':
        return PetModel.fromJson(json);
      case 'services':
        return ServicesModel.fromJson(json);
      case 'electronic_repairing':
        return ElectronicsModel.fromJson(json);
      case 'job':
        return JobModel.fromJson(json);
      case 'smart_phone':
        return SmartPhoneModel.fromJson(json);
      default:
        throw Exception('Unknown product type: $category');
    }
  }
}

import 'package:admin_panel/about_us/screen/about_us_screen.dart';
import 'package:admin_panel/admin_auth/login_page.dart';
import 'package:admin_panel/app_version/app_version.dart';
import 'package:admin_panel/dashboard.dart';
import 'package:admin_panel/feature_request/feature_request_screen.dart';
import 'package:admin_panel/home_page.dart';
import 'package:admin_panel/product/all_product_get.dart';
import 'package:admin_panel/product/product_details_screen/bike/bike_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/book_sport_hobby/book_sports_hobby_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/car/car_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/electronics/electronics_detail_screen.dart';
import 'package:admin_panel/product/product_details_screen/furniture/furniture_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/job/job_details_screens.dart';
import 'package:admin_panel/product/product_details_screen/other/other_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/pet/pet_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/services/services_details_screen.dart';
import 'package:admin_panel/product/product_details_screen/smart_phone/smart_phone_details_screen.dart';
import 'package:admin_panel/report/report_details_screen.dart';
import 'package:admin_panel/report/report_screen.dart';
import 'package:admin_panel/splash_screen.dart';
import 'package:admin_panel/user/user_Screen.dart';
import 'package:admin_panel/user/user_details_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../app_use_guide/screen/app_use_guide_screen.dart';
import '../product/product_details_screen/property/property_details_screen.dart';

class Routs{
  static List<GetPage<dynamic>>? getPages = [
    GetPage(name: AllProductGet.routeName, page: () => AllProductGet()),
    GetPage(name: AdminLoginScreen.routeName, page: () => AdminLoginScreen()),
    GetPage(name: HomeScreen.routeName, page: () => HomeScreen()),
    GetPage(name: Dashboard.routeName, page: () => Dashboard()),
    GetPage(name: SplashScreen.routeName, page: () => SplashScreen()),
    //user routes
     GetPage(name: UserDetailsScreen.routeName, page: () => UserDetailsScreen()),
     GetPage(name: UserScreen.routeName, page: () => UserScreen()),
     GetPage(name: ReportScreen.routeName, page: () => ReportScreen()),
     GetPage(name: ReportDetailsScreen.routeName, page: () => ReportDetailsScreen()),

//product routes
    GetPage(name: BikeDetailsScreen.routeName, page: () => BikeDetailsScreen()),
    GetPage(name: SmartPhoneDetailsScreen.routeName, page: () => SmartPhoneDetailsScreen()),
    GetPage(name: PetDetailsScreen.routeName, page: () => PetDetailsScreen()),
    GetPage(name: JobDetailsScreen.routeName, page: () => JobDetailsScreen()),
    GetPage(name: FurnitureDetailsScreen.routeName, page: () => FurnitureDetailsScreen()),
    GetPage(name: ElectronicsDetailsScreen.routeName, page: () => ElectronicsDetailsScreen()),
    GetPage(name: BookSportsHobbyDetailsScreen.routeName, page: () => BookSportsHobbyDetailsScreen()),
    GetPage(name: CarDetailsScreen.routeName, page: () => CarDetailsScreen()),
    GetPage(name: ServicesDetailScreen.routeName, page: () => ServicesDetailScreen()),
    GetPage(name: OtherProductDetails.routeName, page: () => OtherProductDetails()),
    GetPage(name: PropertyDetailsScreen.routeName, page: () => PropertyDetailsScreen()),
    GetPage(name: AppVersion.routeName, page: () => AppVersion()),
    GetPage(name: FeatureRequestScreen.routeName, page: () => FeatureRequestScreen()),
    GetPage(name: AboutUsScreen.routeName, page: () => AboutUsScreen()),
    GetPage(name: AppUseGuideScreen.routeName, page: () => AppUseGuideScreen()),
  ];
}

import 'package:admin_panel/app_use_guide/provider/app_use_guide_provider.dart';
import 'package:admin_panel/app_version/app_version_provider.dart';
import 'package:admin_panel/feature_request/provider/feature_request_provider.dart';
import 'package:admin_panel/provider/access_code_provider/access_code_provider.dart';
import 'package:admin_panel/provider/admin_login_provider/admin_login_provider.dart';
import 'package:admin_panel/provider/product_provider/product_provider.dart';
import 'package:admin_panel/provider/rate_provider/rate_provider.dart';
import 'package:admin_panel/provider/report_provider/report_provider.dart';
import 'package:admin_panel/provider/tab_provider/tab_provider.dart';
import 'package:admin_panel/provider/user_provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../about_us/provider/about_us_provider.dart';
import '../../provider/dashboard_provider/total_user_provider.dart';

class ProviderList {
  static  List<SingleChildWidget> providers = [
  //  ChangeNotifierProvider(create: (_) => DummyProvider()),

    ChangeNotifierProvider(create: (_) => AdminLoginProvider()),
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => TotalUserProvider()),
    ChangeNotifierProvider(create: (_) => AccessCodeProvider()),
    ChangeNotifierProvider(create: (_) => ReportProvider()),
    ChangeNotifierProvider(create: (_) => TabProvider()),
    ChangeNotifierProvider(create: (_) => AppVersionProvider()),
    ChangeNotifierProvider(create: (_) => RateProvider()),
    ChangeNotifierProvider(create: (_) => FeatureRequestProvider()),
    ChangeNotifierProvider(create: (_) => AboutUsProvider()),
    ChangeNotifierProvider(create: (_) => AppUseGuideProvider()),

  ];
}
import 'constants.dart';

class Apis {
  //   static const String BASE_URL = "https://api.bhavnika.shop/api";
  static const String BASE_URL = "http://localhost:3001/api";
  static const String BASE_URL_IMAGE = "https://api.bhavnika.shop";
  //   static const String SOCKET_URL = "wss://api.bhavnika.shop/";
  static const String SOCKET_URL = "ws://192.168.0.107:3001/";

  // static const String BASE_URL_IMAGE = "http://localhost:3001";

  static const String ADMIN_LOGIN = "$BASE_URL/admin/login";
  static const String PRODUCT_TYPE = "$BASE_URL/admin/get_productS_Type";
  static const String GET_ALL_PRODUCTS =
      '$BASE_URL/admin/get_product_with_type';

  static String GET_PRODUCT_BY_ID(String productId, String modelName) =>
      '$BASE_URL/admin/get-product-by-id?productId=$productId&model=$modelName';
  static const String UPDATE_PRODUCT =
      '$BASE_URL/admin/update_product_for_admin';
  static const String PRODUCT_IMAGE_DELETE_BY_USER =
      BASE_URL + Constants.PRODUCT_IMAGE_DELETE_BY_USER;

  static String GET_USER_BY_ID(String id) =>
      BASE_URL + Constants.GET_USER_BY_ID(id);

  // app version
  static const String CREATE_APP_VERSION = '$BASE_URL/app-version/';
  static const String GET_ALL_APP_VERSIONS = '$BASE_URL/app-version/all';
  static const String GET_LATEST_APP_VERSION = '$BASE_URL/app-version/latest';
  static const String GET_ALL_RATINGS = BASE_URL + Constants.GET_ALL_RATINGS;

  static String GET_APP_VERSION_BY_ID(String id) => '$BASE_URL/app-version/$id';

  static String UPDATE_APP_VERSION_BY_ID(String id) =>
      '$BASE_URL/app-version/$id';

  // feature request
  static const String GET_FEATURE_REQUEST =
      '$BASE_URL${Constants.GET_FEATURE_REQUEST}';

  static String UPDATE_FEATURE_REQUEST_STATUS(String featureRequestId) =>
      '$BASE_URL${Constants.UPDATE_FEATURE_REQUEST_STATUS(featureRequestId)}';

  // app use guide video
  static const String UPLOAD_APP_GUIDE_VIDEO =
      '$BASE_URL${Constants.UPLOAD_APP_GUIDE_VIDEO}';
  static const String GET_APP_GUIDE_VIDEO =
      '$BASE_URL${Constants.GET_APP_GUIDE_VIDEO}';

  static String APP_GUIDE_VIDEO_VISIBILITY_BY_ID(String id) =>
      '$BASE_URL${Constants.APP_GUIDE_VIDEO_VISIBILITY}/$id';

  static String DELETE_APP_GUIDE_VIDEO(String id) =>
      '$BASE_URL${Constants.DELETE_APP_GUIDE_VIDEO(id)}';

  // about us
  static const String GET_ABOUT_US = "$BASE_URL/about-us";
  static const String UPDATE_ABOUT_US = "$BASE_URL/about-us";

  // dashboard / user management
  static const String GET_ALL_USER = "$BASE_URL/admin/get_all_user";
  static const String GET_USER_CATEGORY = "$BASE_URL/admin/get_user_category";
  static String GET_USER_BY_CATEGORY(String category) =>
      "$BASE_URL/admin/get_user_by_userCategory?userCategory=$category";
  static String DELETE_USER_BY_ADMIN(String userId) =>
      "$BASE_URL/admin/delete_user_by_admin?userId=$userId";
  static String USER_ACTIVE_INACTIVE(String userId) =>
      "$BASE_URL/admin/user_active_inActive?userId=$userId";
}

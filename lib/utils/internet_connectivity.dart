import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnectivity {
  static Future<bool> isUserOffline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return true;
    } else {
      final hasConnection = await InternetConnectionChecker().hasConnection;
      return !hasConnection;
    }
  }
}

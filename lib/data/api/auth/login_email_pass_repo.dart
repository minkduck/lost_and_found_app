import 'package:get/get.dart';

import '../../../utils/app_constraints.dart';
import '../api_clients.dart';


class LoginEmailPasswordRepo extends GetxService{
  late ApiClient apiClient;
  LoginEmailPasswordRepo({required this.apiClient});

  Future<Response> getLoginEmailPassword() async {
    return await apiClient.getData(AppConstrants.LOGINEP_URL);
  }
}
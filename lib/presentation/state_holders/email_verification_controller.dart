import 'package:ecommerce/data/models/network_response.dart';
import 'package:ecommerce/data/services/network_caller.dart';
import 'package:ecommerce/data/utility/urls.dart';
import 'package:get/get.dart';

class EmailVerificationController extends GetxController {
  bool _emailVerificationInProgress = false;
  String _message = '';

  bool get emailVerificationInProgress => _emailVerificationInProgress;

  String get message => _message;

  Future<bool> verifyEmail(String email) async {
    _emailVerificationInProgress = true;
    update();
    final NetworkResponse response = await NetworkCaller.getRequest(Urls.verifyEmail(email));
    _emailVerificationInProgress = false;
    update();
    if (response.isSuccess) {
      _message = response.responseJson?['data'] ?? '';
      return true;
    } else {
      _message = 'Email verification failed! Try again';
      return false;
    }
  }

  Future<void> resendEmailVerification(String email) async {
    final NetworkResponse response = await NetworkCaller.getRequest(Urls.verifyEmail(email));

    if (response.isSuccess) {
      _message = response.responseJson?['data'] ?? '';
      // Optionally, you can show a success message here
      update();
    } else {
      _message = 'Failed to resend email verification! Try again';
      // Optionally, you can show an error message here
      update();
    }
  }
}


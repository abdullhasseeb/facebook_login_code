import 'package:e_commerce/data/repositories/authentication_repository.dart';
import 'package:e_commerce/data/repositories/user/user_repository.dart';
import 'package:e_commerce/features/personalization/controllers/user_controller.dart';
import 'package:e_commerce/utils/helpers/network_manager.dart';
import 'package:e_commerce/utils/popups/full_screen_loader.dart';
import 'package:e_commerce/utils/popups/snackbar_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AddEmailController extends GetxController{
  static AddEmailController get instance => Get.find();

  /// Variables
  final _userController = Get.put(UserController());
  final _userRepository = Get.put(UserRepository());

  final email = TextEditingController();
  final addEmailFormKey = GlobalKey<FormState>();
  RxBool isLinkSent = false.obs;

  /// Send Verification Link To Add Email
  Future<void> saveEmail() async{
    try{

      // Start Loading
      UFullScreenLoader.openLoadingDialog('Sending verification link...');

      // Check Internet Connectivity
      bool isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        UFullScreenLoader.stopLoading();
        USnackBarHelpers.warningSnackBar(title: 'No Internet Connection');
        return;
      }

      // Form Validation
      if(!addEmailFormKey.currentState!.validate()){
        UFullScreenLoader.stopLoading();
        return;
      }

      final String enteredEmail = email.text.trim();
      await AuthenticationRepository.instance.verifyBeforeUpdateEmail(enteredEmail);

      // Update Email In Fire store
      await _userRepository.updateSingleField({'email': enteredEmail});

      // Update Email In RX User
      _userController.user.value.email = enteredEmail;
      _userController.user.refresh();

      // Show Link Sent State
      isLinkSent.value = true;

      // Stop Loading
      UFullScreenLoader.stopLoading();

      // Success Message
      USnackBarHelpers.successSnackBar(title: 'Email Sent', message: 'Verification link sent to $enteredEmail');

    }catch(e){
      // Stop Loading
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(title: 'Email Failed!', message: e.toString());
    }
  }

  /// Check If User Verified The New Email
  Future<void> checkEmailVerificationStatus() async{
    try{

      // Start Loading
      UFullScreenLoader.openLoadingDialog('Checking verification...');

      // Reload User From Firebase
      await FirebaseAuth.instance.currentUser!.reload();
      final String authEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      // Stop Loading
      UFullScreenLoader.stopLoading();

      // Email Updated Without Session Expiry
      if(authEmail.isNotEmpty){
        AuthenticationRepository.instance.screenRedirect();
        return;
      }

      // Not Verified Yet
      USnackBarHelpers.warningSnackBar(title: 'Not Verified Yet', message: 'Please open the link we sent to your email');

    } on FirebaseAuthException catch(exception){
      UFullScreenLoader.stopLoading();

      // Email change revokes the session, so verified users must log in again
      if(exception.code == 'user-token-expired' || exception.code == 'invalid-user-token'){
        await AuthenticationRepository.instance.logout();
        USnackBarHelpers.successSnackBar(title: 'Email Verified', message: 'Please log in again with Facebook');
        return;
      }
      USnackBarHelpers.errorSnackBar(title: 'Error', message: exception.message ?? 'Something went wrong');

    }catch(e){
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Change Email If User Typed Wrong One
  void changeEmail() => isLinkSent.value = false;

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }
}

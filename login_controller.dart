import 'package:e_commerce/features/authentication/screens/add_email/add_email.dart';
import 'package:e_commerce/data/repositories/authentication_repository.dart';
import 'package:e_commerce/features/personalization/controllers/user_controller.dart';
import 'package:e_commerce/utils/constants/keys.dart';
import 'package:e_commerce/utils/helpers/network_manager.dart';
import 'package:e_commerce/utils/popups/full_screen_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../utils/popups/snackbar_helpers.dart';

class LoginController extends GetxController{
  static LoginController get instance => Get.find();

  /// Variables

  final email = TextEditingController();
  final password = TextEditingController();
  RxBool isPasswordVisible = false.obs;
  RxBool rememberMe = false.obs;
  final loginFormKey = GlobalKey<FormState>();
  final localStorage = GetStorage();


  @override
  void onInit() {
    email.text = localStorage.read(UKeys.rememberMeEmail) ?? '';
    password.text = localStorage.read(UKeys.rememberMePassword) ?? '';
    super.onInit();
  }

  /// Function to login the user with email and password
  Future<void> loginWithEmailAndPassword() async{
    try{

      // Start Loading
      UFullScreenLoader.openLoadingDialog('Logging you in...');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        UFullScreenLoader.stopLoading();
        USnackBarHelpers.warningSnackBar(title: 'No Internet Connection');
        return;
      }

      // Form Validation
      if(!loginFormKey.currentState!.validate()){
        UFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if remember me is checked
      if(rememberMe.value){
        localStorage.write(UKeys.rememberMeEmail, email.text.trim());
        localStorage.write(UKeys.rememberMePassword, password.text.trim());
      }

      // Login User with Email and Password
      await AuthenticationRepository.instance.loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Stop Loading
      UFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();

    }catch(e){
      UFullScreenLoader.stopLoading();
      USnackBarHelpers.errorSnackBar(title: 'Login Failed', message: e.toString());
    }
  }

  /// Google Sign In Authentication
  Future<void> googleSignIn() async{
    try{

      // Start Loading
      UFullScreenLoader.openLoadingDialog('Logging you in...');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        UFullScreenLoader.stopLoading();
        USnackBarHelpers.warningSnackBar(title: 'No Internet Connection');
        return;
      }

      // Google Authentication
      UserCredential userCredential = await AuthenticationRepository.instance.signInWithGoogle();

      // Save User Record
      await Get.put(UserController()).saveUserRecord(userCredential);

      // Stop Loading
      UFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();

    }catch(e){
      // Stop Loading
      UFullScreenLoader.stopLoading();
      // Error Snack-bar
      USnackBarHelpers.errorSnackBar(title: 'Login Failed', message: e.toString());
    }
  }

  Future<void> facebookSignIn() async{
    try{
      // start loading
      UFullScreenLoader.openLoadingDialog('Logging you in...');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        UFullScreenLoader.stopLoading();
        USnackBarHelpers.warningSnackBar(title: 'No Internet Connection');
        return;
      }

      // login with facebook
      UserCredential? userCredential = await AuthenticationRepository.instance.signInWithFacebookFirebase();
      if(userCredential == null){
        UFullScreenLoader.stopLoading();
        return;
      }

      // Save User Record
      final userController = Get.put(UserController());
      await userController.saveUserRecord(userCredential);

      // Stop Loading
      UFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();

    }catch(e){
      // Stop Loading
      UFullScreenLoader.stopLoading();
      // Error Snack-bar
      USnackBarHelpers.errorSnackBar(title: 'Login Failed', message: e.toString());
    }
  }
}

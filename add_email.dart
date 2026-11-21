import 'package:e_commerce/common/style/padding.dart';
import 'package:e_commerce/common/widgets/button/elevated_button.dart';
import 'package:e_commerce/data/repositories/authentication_repository.dart';
import 'package:e_commerce/features/authentication/controllers/add_email/add_email_controller.dart';
import 'package:e_commerce/utils/constants/sizes.dart';
import 'package:e_commerce/utils/constants/texts.dart';
import 'package:e_commerce/utils/validators/validation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AddEmailScreen extends StatelessWidget {
  const AddEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddEmailController());
    return Scaffold(
      /// [AppBar] - Logout if user does not want to continue
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: AuthenticationRepository.instance.logout, icon: Icon(CupertinoIcons.clear))],
      ),

      /// [Body]
      body: SingleChildScrollView(
        child: Padding(
          padding: UPadding.screenPadding,
          child: Obx(
                () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                Text(
                  controller.isLinkSent.value ? UTexts.addEmailLinkSentTitle : UTexts.addEmailTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: USizes.spaceBtwItems / 2),

                /// SubTitle
                Text(
                  controller.isLinkSent.value ? UTexts.addEmailLinkSentSubTitle : UTexts.addEmailSubTitle,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                SizedBox(height: USizes.spaceBtwSections * 2),

                /// Email
                Form(
                  key: controller.addEmailFormKey,
                  child: TextFormField(
                    controller: controller.email,
                    enabled: !controller.isLinkSent.value,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => UValidator.validateEmail(value),
                    decoration: InputDecoration(labelText: UTexts.email, prefixIcon: Icon(Iconsax.direct_right)),
                  ),
                ),
                SizedBox(height: USizes.spaceBtwItems),

                /// Send Link Or Check Verification
                controller.isLinkSent.value
                    ? UElevatedButton(onPressed: controller.checkEmailVerificationStatus, child: Text(UTexts.iHaveVerified))
                    : UElevatedButton(onPressed: controller.saveEmail, child: Text(UTexts.uContinue)),

                /// Resend And Change Email
                if (controller.isLinkSent.value) ...[
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(onPressed: controller.saveEmail, child: Text(UTexts.resendEmail)),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(onPressed: controller.changeEmail, child: Text(UTexts.changeEmail)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/sign_up_body.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/test_field_title.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  // Focus nodes
  final FocusNode fNameNode = FocusNode();
  final FocusNode lNameNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode passwordNode = FocusNode();
  final FocusNode confirmPasswordNode = FocusNode();
  final FocusNode referralNode = FocusNode();

  // Step state
  int _currentStep = 0;

  bool get _referralEnabled =>
      Get.find<ConfigController>().config?.referralEarningStatus ?? false;

  /// Steps:
  /// 0: firstName, 1: lastName, 2: phone, 3: password, 4: confirmPassword, (5: referral if enabled)
  int get _lastStepIndex => _referralEnabled ? 5 : 4;

  @override
  void initState() {
    super.initState();
    // Initialize dial code from config
    final cfg = Get.find<ConfigController>().config;
    if (cfg?.countryCode != null) {
      Get.find<AuthController>().countryDialCode =
          CountryCode.fromCountryCode(cfg!.countryCode!).dialCode!;
    }
  }

  // Navigation
  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _next(AuthController authController) {
    if (_validateCurrentStep(authController)) {
      if (_currentStep < _lastStepIndex) {
        setState(() => _currentStep++);
      } else {
        _submit(authController);
      }
    }
  }

  // Validation per step
  bool _validateCurrentStep(AuthController authController) {
    final fName = fNameController.text.trim();
    final lName = lNameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    switch (_currentStep) {
      case 0:
        if (fName.isEmpty) {
          showCustomSnackBar('first_name_is_required'.tr);
          FocusScope.of(context).requestFocus(fNameNode);
          return false;
        }
        return true;
      case 1:
        if (lName.isEmpty) {
          showCustomSnackBar('last_name_is_required'.tr);
          FocusScope.of(context).requestFocus(lNameNode);
          return false;
        }
        return true;
      case 2:
        if (phone.isEmpty) {
          showCustomSnackBar('phone_is_required'.tr);
          FocusScope.of(context).requestFocus(phoneNode);
          return false;
        }
        if (!GetUtils.isPhoneNumber(authController.countryDialCode + phone)) {
          showCustomSnackBar('phone_number_is_not_valid'.tr);
          FocusScope.of(context).requestFocus(phoneNode);
          return false;
        }
        return true;
      case 3:
        if (password.isEmpty) {
          showCustomSnackBar('password_is_required'.tr);
          FocusScope.of(context).requestFocus(passwordNode);
          return false;
        }
        if (password.length < 8) {
          showCustomSnackBar('minimum_password_length_is_8'.tr);
          FocusScope.of(context).requestFocus(passwordNode);
          return false;
        }
        return true;
      case 4:
        if (confirmPassword.isEmpty) {
          showCustomSnackBar('confirm_password_is_required'.tr);
          FocusScope.of(context).requestFocus(confirmPasswordNode);
          return false;
        }
        if (password != confirmPassword) {
          showCustomSnackBar('password_is_mismatch'.tr);
          FocusScope.of(context).requestFocus(confirmPasswordNode);
          return false;
        }
        return true;
      case 5: // referral is optional
        return true;
      default:
        return true;
    }
  }

  // Submit
  void _submit(AuthController authController) {
    final fName = fNameController.text.trim();
    final lName = lNameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Quick final check
    if (fName.isEmpty ||
        lName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showCustomSnackBar('please_fill_all_required_fields'.tr);
      return;
    }

    authController.register(SignUpBody(
      fName: fName,
      lName: lName,
      phone: authController.countryDialCode + phone,
      password: password,
      confirmPassword: confirmPassword,
      referralCode: referralCodeController.text.trim(),
    ));
  }

  // Step title
  Widget _stepTitle() {
    final titles = <String>[
      'first_name'.tr,
      'last_name'.tr,
      'phone'.tr,
      'password'.tr,
      'confirm_password'.tr,
      if (_referralEnabled) 'refer_code'.tr,
    ];
    return Text(
      titles[_currentStep],
      style: textBold.copyWith(
        color: Theme.of(context).primaryColor,
        fontSize: Dimensions.fontSizeLarge,
      ),
    );
  }

  // Field per step
  Widget _buildStepField(AuthController authController) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'first_name'.tr),
            CustomTextField(
              capitalization: TextCapitalization.words,
              hintText: 'first_name'.tr,
              inputType: TextInputType.name,
              prefixIcon: Images.person,
              controller: fNameController,
              focusNode: fNameNode,
              nextFocus: lNameNode,
              inputAction: TextInputAction.next,
              prefixHeight: 70,
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'last_name'.tr),
            CustomTextField(
              capitalization: TextCapitalization.words,
              hintText: 'last_name'.tr,
              inputType: TextInputType.name,
              prefixIcon: Images.person,
              controller: lNameController,
              focusNode: lNameNode,
              nextFocus: phoneNode,
              inputAction: TextInputAction.next,
              prefixHeight: 70,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'phone'.tr),
            CustomTextField(
              hintText: 'phone'.tr,
              inputType: TextInputType.number,
              countryDialCode: authController.countryDialCode,
              controller: phoneController,
              focusNode: phoneNode,
              nextFocus: passwordNode,
              inputAction: TextInputAction.next,
              onCountryChanged: (CountryCode cc) {
                authController.countryDialCode = cc.dialCode!;
                authController.setCountryCode(cc.dialCode!);
                FocusScope.of(context).requestFocus(phoneNode);
              },
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'password'.tr),
            CustomTextField(
              hintText: 'enter_password'.tr,
              inputType: TextInputType.text,
              prefixIcon: Images.password,
              isPassword: true,
              controller: passwordController,
              focusNode: passwordNode,
              nextFocus: confirmPasswordNode,
              inputAction: TextInputAction.next,
              prefixHeight: 70,
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'confirm_password'.tr),
            CustomTextField(
              hintText: 'enter_confirm_password'.tr,
              inputType: TextInputType.text,
              prefixIcon: Images.password,
              isPassword: true,
              controller: confirmPasswordController,
              focusNode: confirmPasswordNode,
              nextFocus: _referralEnabled ? referralNode : null,
              inputAction: _referralEnabled ? TextInputAction.next : TextInputAction.done,
              prefixHeight: 70,
            ),
          ],
        );
      case 5: // referral (optional)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldTitle(title: 'refer_code'.tr),
            CustomTextField(
              hintText: 'refer_code'.tr,
              inputType: TextInputType.text,
              controller: referralCodeController,
              focusNode: referralNode,
              inputAction: TextInputAction.done,
              prefixIcon: Images.referralIcon1,
              prefixHeight: 70,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Controls (Back / Next / Submit)
  Widget _stepControls(AuthController authController) {
    final isLast = _currentStep == _lastStepIndex;

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: ButtonWidget(
              buttonText: 'Back',
              onPressed: _back,
              height: 45,
              //radius: 20,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).primaryColor,
              showBorder: true,
              borderColor: Theme.of(context).primaryColor,
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: ButtonWidget(
            buttonText: isLast ? 'submit'.tr : 'next'.tr,
            onPressed: () => _next(authController),
            height: 45,
            //radius: 50,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: GetBuilder<AuthController>(builder: (authController) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo / Header
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(Images.signUpScreenLogo, width: 150),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                    // Title
                    Center(
                      child: Text(
                        'sign_up'.tr,
                        textAlign: TextAlign.center,
                        style: textBold.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: Dimensions.fontSizeOverLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    // Step title
                    _stepTitle(),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Current step field
                    _buildStepField(authController),
                    const SizedBox(height: Dimensions.paddingSizeLarge * 1.5),

                    // Controls or loader
                    authController.isLoading
                        ? Center(
                            child: SpinKitCircle(
                              color: Theme.of(context).primaryColor,
                              size: 40.0,
                            ),
                          )
                        : _stepControls(authController),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Step progress
                    Center(
                      child: Text(
                        '${'step'.tr} ${_currentStep + 1} / ${_lastStepIndex + 1}',
                        style: textRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Footer: Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${'already_have_an_account'.tr} ',
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        ButtonWidget(
                          buttonText: 'Login',
                          onPressed: () => Get.back(),
                          width: 120,
                          fontSize: Dimensions.fontSizeSmall,
                          //radius: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

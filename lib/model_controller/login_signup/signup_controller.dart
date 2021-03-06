// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_constructors, avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_parking/main.dart';
import 'package:smart_parking/view/login_signup/verification_code.dart';

import '../../switch_login.dart';

class SignupController extends GetxController {
  late String name = '',
      password = '',
      verificationID;
  bool showPassword=false;
  TextEditingController phoneNumber=TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController otpController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
@override
  onInit(){
  phoneNumber.text='+2';
  super.onInit();
}


  singUp() async {

    //لتاكيد الفنكشن ان الكلام مكتوب بشكل مظبوط
    if (formState.currentState!.validate()) {
      auth.verifyPhoneNumber(
          phoneNumber: phoneNumber.text,  timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await auth.signInWithCredential(credential).then((value) async {
              print(auth.currentUser!.uid);
              GetStorage().write("phoneNumber", phoneNumber.text);
              await FirebaseDatabase.instance.ref('users/${phoneNumber.text}').set({
                "name": name,
                "slotReserved": '',
                "startTimeOfBooking": '',
                'garageReserved':'',
                'phoneNumber': phoneNumber.text,
                'password': password,
                'inGarage': false,
                'isReservation': false,

              }).then((value) {
                Get.offAll(SwitchLogin());
              });
              print("You are logged in successfully");
            });
          },
          verificationFailed: (FirebaseAuthException e) {
            print(e.message);
          },
          codeSent: (String verificationId, int? resendToken) async {
            //after send sms
            verificationID = verificationId;
            Get.to(() => PinCodeVerificationScreen());
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    }
  }

  void verifyOTP() async {
     PhoneAuthProvider.credential(
        verificationId: verificationID,
        smsCode: otpController.text
    );

  }
}

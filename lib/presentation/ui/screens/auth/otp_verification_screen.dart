import 'package:ecommerce/presentation/state_holders/email_verification_controller.dart';
import 'package:ecommerce/presentation/state_holders/otp_verification_controller.dart';
import 'package:ecommerce/presentation/ui/screens/main_bottom_nav_screen.dart';
import 'package:ecommerce/presentation/ui/utility/app_colors.dart';
import 'package:ecommerce/presentation/ui/utility/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {

  final TextEditingController _otpTEController = TextEditingController();
  late Timer _timer;
  int _secondsRemaining = 120;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else
        (_timer.cancel());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                Center(
                  child: SvgPicture.asset(
                    ImageAssets.craftyBayLogoSVG,
                    width: 100,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Enter your OTP code',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                      ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text('A 4 digit OTP code has been sent',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey)),
                const SizedBox(
                  height: 24,
                ),
                PinCodeTextField(
                  controller: _otpTEController,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: AppColors.primaryColor,
                    inactiveColor: AppColors.primaryColor,
                    selectedColor: Colors.green,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  onCompleted: (v) {},
                  onChanged: (value) {},
                  beforeTextPaste: (text) {
                    return true;
                  },
                  appContext: context,
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  child: GetBuilder<OtpVerificationController>(
                      builder: (controller) {
                    if (controller.otpVerificationInProgress) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ElevatedButton(
                      onPressed: () {
                        verifyOtp(controller);
                      },
                      child: const Text('Next'),
                    );
                  }),
                ),
                const SizedBox(
                  height: 24,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(text: 'This code will expire in '),
                      TextSpan(
                        text: '$_secondsRemaining s',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _secondsRemaining > 0
                      ? null
                      : () {
                          // Add logic to resend OTP here
                          // For example, you can call a function to resend OTP
                          resendOtp();
                          // Restart the timer
                          setState(() {
                            _secondsRemaining = 120;
                          });
                          startTimer();
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: _secondsRemaining > 0
                        ? Colors.grey
                        : AppColors.primaryColor,
                  ),
                  child: const Text('Resend'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> verifyOtp(OtpVerificationController controller) async {
    final response =
        await controller.verifyOtp(widget.email, _otpTEController.text.trim());
    if (response) {
      Get.offAll(() => const MainBottomNavScreen());
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Otp verification failed! Try again'),
          ),
        );
      }
    }
  }

  Future<void> resendOtp() async {
    EmailVerificationController emailController = EmailVerificationController();
    bool verificationSuccess = await emailController.verifyEmail(widget.email);

    // Check if the verification was successful
    if (verificationSuccess) {
      // Reset the countdown to 120 seconds
      _secondsRemaining = 120;
      startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend verification code. Try again.'),
        ),
      );
    }
  }
}

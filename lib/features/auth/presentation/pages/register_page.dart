import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends GetView<AuthController> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    if (!Get.isRegistered<AuthController>()) {
      Get.find<AuthController>();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.rocket_launch_rounded, size: 80, color: Color(0xFF2563EB)),
                const SizedBox(height: 16),
                Text(
                  'Join Nexus',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journey with us today',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (emailController.text.isEmpty || 
                              passwordController.text.isEmpty) {
                            Get.snackbar('Error', 'Please fill in all fields');
                            return;
                          }
                          if (passwordController.text != confirmPasswordController.text) {
                            Get.snackbar('Error', 'Passwords do not match');
                            return;
                          }
                          controller.register(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Text('Create Account'),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

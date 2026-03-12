import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Libération de la mémoire
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.login)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.login,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Champ Email
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.emailRequired;
                    } else if (!value.contains('@')) {
                      return AppStrings.emailInvalid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ Mot de passe
                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    } else if (value.length < 6) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),

                // Visibility(
                //   visible: authProvider.error != null,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 16),
                //     child: Text(
                //       authProvider.error ?? '',
                //       style: TextStyle(color: AppColors.error),
                //     ),
                //   ),
                // ),

                const SizedBox(height: 24),

                // Bouton Connexion
                CustomButton(
                  text: AppStrings.login,
                  // isLoading: authProvider.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // bool success = await context.read<AuthProvider>().login(
                      //   _emailController.text,
                      //   _passwordController.text,
                      // );

                      // if (success && mounted) {
                      //   Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => const HomeScreen()),
                      //   );
                      // }
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Lien Inscription
                TextButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    // );
                  },
                  child: const Text(AppStrings.noAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
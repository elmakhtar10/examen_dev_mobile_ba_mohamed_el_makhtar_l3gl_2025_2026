import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.register)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.createAccount,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Champ Nom complet
                CustomTextField(
                  label: AppStrings.name,
                  controller: _nameController,
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppStrings.nameRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Email
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppStrings.emailRequired;
                    if (!value.contains('@')) return AppStrings.emailInvalid;
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
                    if (value == null || value.length < 6) return AppStrings.passwordTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Confirmer Mot de Passe
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppStrings.requiredConfirmPassword;
                    if (value != _passwordController.text) return AppStrings.passwordsNotMatch;
                    return null;
                  },
                ),

                Visibility(
                  visible: authProvider.error != null,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      authProvider.error ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                CustomButton(
                  text: AppStrings.register,
                  isLoading: authProvider.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await context.read<AuthProvider>().register(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                      );

                      if (success && mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.haveAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
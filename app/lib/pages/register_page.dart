// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:app/components/my_button.dart';
import 'package:app/components/my_tex_field.dart';
import 'package:app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() async {
    if(passwordController.text != confirmPasswordController.text){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password do not match"),),);
      return;
    }
    final authService = Provider.of<AuthService>(context, listen: false);
    try{
      await  authService.signUpWithEmailandPassword(emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()),),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 152, 205, 248),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // Logo
                  Icon(
                    Icons.message,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 50),

                  // Welcome
                  const Text(
                    "Registrarse",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Email
                  MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),
                  const SizedBox(height: 10),

                  // Password
                  MyTextField(
                      controller: passwordController,
                      hintText: 'Contraseña',
                      obscureText: true),
                  const SizedBox(height: 25),

                  // Confirm Password
                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirma tu contraseña',
                      obscureText: true),
                  const SizedBox(height: 25),

                  // Sign up
                  MyButton(onTap: signUp, text: "Sign up"),

                  const SizedBox(height: 50),

                  // Log in now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already a member?'),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Log in now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

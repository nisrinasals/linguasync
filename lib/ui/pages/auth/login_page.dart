import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/auth/auth_bloc.dart';
import '../../../../logic/bloc/auth/auth_event.dart';
import '../../../../logic/bloc/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/japandi_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginSubmitted() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        LoginSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.user.role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/main');
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: JC.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.translate, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 28),
                    const Text('Selamat Datang', style: JT.displaySm),
                    const SizedBox(height: 6),
                    Text(
                      'Masuk untuk melanjutkan perjalanan belajar Anda',
                      style: JT.bodySm,
                    ),
                    const SizedBox(height: 36),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Alamat Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Email wajib diisi';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Kata Sandi',
                      isPassword: true,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Kata sandi wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomButton(
                          text: 'Masuk Akun',
                          onPressed: _onLoginSubmitted,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum memiliki akun? ', style: JT.bodySm),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              color: JC.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
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
      ),
    );
  }
}

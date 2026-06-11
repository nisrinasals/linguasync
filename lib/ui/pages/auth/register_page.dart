import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linguasync/logic/bloc/auth/auth_bloc.dart';
import 'package:linguasync/logic/bloc/auth/auth_event.dart';
import 'package:linguasync/logic/bloc/auth/auth_state.dart';
import 'package:linguasync/ui/widgets/custom_button.dart';
import 'package:linguasync/ui/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterSubmitted() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        RegisterSubmitted(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccessMessage) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is Authenticated) {
            if (state.user.role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/explore-language');
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lengkapi form untuk bergabung ke LinguaSync',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    validator: (val) => val == null || val.isEmpty
                        ? 'Nama lengkap wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Alamat Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Email wajib diisi';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(val)) {
                        return 'Format penulisan email salah';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Kata Sandi',
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Kata sandi wajib diisi';
                      if (val.length < 6)
                        return 'Kata sandi minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Konfirmasi Kata Sandi',
                    isPassword: true,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Konfirmasi kata sandi wajib diisi';
                      if (val != _passwordController.text)
                        return 'Kata sandi tidak cocok';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Daftar Akun',
                        onPressed: _onRegisterSubmitted,
                        isLoading: state is AuthLoading,
                      );
                    },
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/auth/auth_bloc.dart';
import '../../../../logic/bloc/auth/auth_event.dart';
import '../../../../logic/bloc/auth/auth_state.dart';
import '../../theme/japandi_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JC.bg,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.user.role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/main');
            }
          } else if (state is Unauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo mark
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: JC.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.translate,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'LinguaSync',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: JC.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Belajar bahasa dengan tenang',
                style: JT.bodySm,
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: JC.primary,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

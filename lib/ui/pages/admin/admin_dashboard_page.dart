import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linguasync/logic/bloc/auth/auth_bloc.dart';
import '../../../logic/bloc/auth/auth_event.dart';
import '../../../logic/bloc/auth/auth_state.dart';
import '../../theme/japandi_theme.dart';
import 'admin_manage_language_page.dart';
import 'admin_manage_user_page.dart';
import 'admin_manage_history_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final adminName = authState is Authenticated
        ? authState.user.name
        : 'Administrator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text(
                      'Apakah Anda yakin ingin keluar dari aplikasi?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<AuthBloc>().add(LogoutRequested());
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: JC.error),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: JC.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $adminName',
                    style: JT.titleLg.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Selamat datang kembali!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Menu Manajemen Utama',
              style: JT.titleMd,
            ),
            const SizedBox(height: 16),

            // Card 1: Kelola Bahasa
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminManageLanguagePage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: JC.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: JC.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: JC.primarySfc,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dns,
                        color: JC.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Ekosistem Bahasa',
                            style: JT.titleMd,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pusat kendali CRUD Bahasa, Materi Teks bab, beserta Bank Soal Evaluasi Kuis.',
                            style: JT.bodySm,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: JC.inkLt,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Kelola Pengguna
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminManageUserPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: JC.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: JC.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: JC.primarySfc,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: JC.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Pengguna',
                            style: JT.titleMd,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pusat kendali CRUD Akun Pengguna / Siswa dan penugasan wewenang admin.',
                            style: JT.bodySm,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: JC.inkLt,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Kelola Riwayat Kuis
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminManageHistoryPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: JC.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: JC.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: JC.primarySfc,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history_edu,
                        color: JC.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Riwayat Kuis',
                            style: JT.titleMd,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pusat kendali CRUD Riwayat Kuis siswa dan penyesuaian nilai hasil belajar.',
                            style: JT.bodySm,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: JC.inkLt,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

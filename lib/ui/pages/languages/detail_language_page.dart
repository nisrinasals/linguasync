import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/language_model.dart';
import '../../../../logic/bloc/language/language_bloc.dart';
import '../../../../logic/bloc/language/language_event.dart';
import '../../../../logic/bloc/language/language_state.dart';

class DetailLanguagePage extends StatefulWidget {
  final LanguageModel language;

  const DetailLanguagePage({super.key, required this.language});

  @override
  State<DetailLanguagePage> createState() => _DetailLanguagePageState();
}

class _DetailLanguagePageState extends State<DetailLanguagePage> {
  late bool _isEnrolled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEnrolled = widget.language.isEnrolled;
  }

  void _handleSuccess(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isEnrolled = !_isEnrolled;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleFailure(String error) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  void _confirmUnenroll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Kelas'),
        content: const Text('Apakah Anda yakin ingin keluar dari kelas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              context.read<LanguageBloc>().add(
                UnenrollLanguageRequested(enrollmentId: widget.language.id),
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _enroll() {
    setState(() => _isLoading = true);
    context.read<LanguageBloc>().add(
      EnrollLanguageRequested(languageId: widget.language.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // PopScope mengunci navigasi back jika _isLoading true
    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mohon tunggu, proses sedang berlangsung...'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.language.name), centerTitle: true),
        body: SafeArea(
          child: BlocListener<LanguageBloc, LanguageState>(
            listener: (context, state) {
              if (state is LanguageOperationSuccess) {
                _handleSuccess(state.message);
              } else if (state is LanguageFailure) {
                _handleFailure(state.error);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.translate,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.language.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isEnrolled ? 'Sedang Diikuti' : 'Belum Diikuti',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Deskripsi Bahasa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.language.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Button
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_isEnrolled ? _confirmUnenroll : _enroll),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEnrolled
                          ? Colors.red.shade400
                          : primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEnrolled ? 'Keluar Kelas' : 'Ikuti Kelas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

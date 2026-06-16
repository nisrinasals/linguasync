import 'package:flutter/material.dart';
import 'package:linguasync/data/models/history_model.dart';
import '../../theme/japandi_theme.dart';

class QuizHistoryDetailPage extends StatelessWidget {
  final HistoryModel history;

  const QuizHistoryDetailPage({super.key, required this.history});

  String _formatDateTime(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final months = [
        'Januari','Februari','Maret','April','Mei','Juni',
        'Juli','Agustus','September','Oktober','November','Desember'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month ${dt.year}, $hour:$minute';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = history.score >= 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Kuis')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Score hero card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  color: isPassed ? JC.successLt : JC.errorLt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPassed ? JC.success : JC.error,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Score circle
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        color: isPassed ? JC.success : JC.error,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            history.score.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const Text(
                            'pts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPassed ? Icons.check_circle : Icons.error_outline,
                            color: isPassed ? JC.success : JC.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPassed ? 'LULUS' : 'BELUM LULUS',
                            style: TextStyle(
                              color: isPassed ? JC.success : JC.error,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPassed
                          ? 'Selamat! Pertahankan semangat belajar Anda.'
                          : 'Jangan menyerah. Pelajari lagi dan coba kembali.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isPassed ? JC.success : JC.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Detail section header
              const Padding(
                padding: EdgeInsets.only(left: 2, bottom: 12),
                child: Text('Rincian Pengerjaan', style: JT.titleMd),
              ),

              // Detail card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildRow(Icons.language, 'Bahasa', history.languageName ?? '-'),
                      const Divider(height: 24),
                      _buildRow(Icons.calendar_today_outlined, 'Tanggal Pengerjaan',
                          _formatDateTime(history.createdAt)),
                      const Divider(height: 24),
                      _buildRow(Icons.tag, 'ID Riwayat', '#${history.id}'),
                      const Divider(height: 24),
                      _buildRow(
                        isPassed ? Icons.verified_outlined : Icons.close_rounded,
                        'Status',
                        isPassed ? 'Lulus (≥ 60 pts)' : 'Tidak Lulus (< 60 pts)',
                        valueColor: isPassed ? JC.success : JC.error,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Riwayat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: JC.primary, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: JT.caption),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? JC.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

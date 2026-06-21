import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/leaderboard_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../theme/japandi_theme.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardModel leaderboard;

  const LeaderboardTile({super.key, required this.leaderboard});

  Color _getRankBgColor() {
    if (leaderboard.rank == 1) return JC.gold;
    if (leaderboard.rank == 2) return JC.silver;
    if (leaderboard.rank == 3) return JC.bronze;
    return JC.bgMuted;
  }

  Color _getRankTextColor() {
    if (leaderboard.rank <= 3) return Colors.white;
    return JC.inkMd;
  }

  Widget _buildAvatar(BuildContext context) {
    final storageProvider = context.read<AuthRepository>().storageProvider;
    final hasPhoto = leaderboard.fotoProfile != null && leaderboard.fotoProfile!.isNotEmpty;
    return CircleAvatar(
      radius: 18,
      backgroundColor: JC.primary.withOpacity(0.1),
      backgroundImage: hasPhoto
          ? NetworkImage(storageProvider.getProfileImageUrl(leaderboard.fotoProfile))
          : null,
      child: !hasPhoto
          ? const Icon(Icons.person, color: JC.primary, size: 18)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = leaderboard.rank <= 3;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getRankBgColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                leaderboard.rank.toString(),
                style: TextStyle(
                  color: _getRankTextColor(),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Profile Picture
            _buildAvatar(context),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                leaderboard.name,
                style: JT.titleMd.copyWith(
                  fontWeight: isTop3 ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: JC.primarySfc,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${leaderboard.totalScore.toStringAsFixed(0)} pts',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: JC.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

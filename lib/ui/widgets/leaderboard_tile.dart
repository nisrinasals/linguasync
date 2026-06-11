import 'package:flutter/material.dart';
import '../../data/models/leaderboard_model.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardModel leaderboard;

  const LeaderboardTile({super.key, required this.leaderboard});

  Color? _getRankColor() {
    if (leaderboard.rank == 1) return const Color(0xFFFFD700);
    if (leaderboard.rank == 2) return const Color(0xFFC0C0C0);
    if (leaderboard.rank == 3) return const Color(0xFFCD7F32);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: rankColor ?? Colors.grey[200],
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            leaderboard.rank.toString(),
            style: TextStyle(
              color: rankColor != null ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          leaderboard.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '${leaderboard.totalScore.toStringAsFixed(0)} Pts',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
    );
  }
}

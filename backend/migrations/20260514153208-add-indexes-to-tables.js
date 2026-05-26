"use strict";

module.exports = {
  async up(queryInterface, Sequelize) {
    // --- 1. TABEL users ---
    await queryInterface.addIndex("Users", ["email"], {
      unique: true,
      name: "idx_users_email",
    });

    // --- 2. TABEL languages ---
    await queryInterface.addIndex("Languages", ["name"], {
      name: "idx_languages_name",
    });

    // --- 3. TABEL materials ---
    await queryInterface.addIndex("Materials", ["language_id"], {
      name: "idx_materials_lang",
    });
    await queryInterface.addIndex("Materials", ["order_index"], {
      name: "idx_materials_order",
    });

    // --- 4. TABEL quizzes  ---
    await queryInterface.addIndex("Quizzes", ["language_id"], {
      name: "idx_quizzes_lang",
    });

    // --- 5. TABEL Enrollments ---
    await queryInterface.addIndex("Enrollments", ["user_id", "language_id"], {
      unique: true,
      name: "idx_enrollments_user_lang",
    });

    // --- 6. TABEL quiz_history ---
    // Index untuk riwayat pribadi
    await queryInterface.addIndex("QuizHistories", ["user_id"], {
      name: "idx_quizhistories_user",
    });

    // Composite Index untuk Leaderboard (Logic Latest Score)
    await queryInterface.addIndex("QuizHistories", ["user_id", "quiz_id", "createdAt"], {
      name: "idx_leaderboard_latest",
    });

    // Index score untuk sorting
    await queryInterface.addIndex("QuizHistories", ["score"], {
      name: "idx_quizhistories_score",
    });
  },

  async down(queryInterface, Sequelize) {
    // Menghapus index berdasarkan NAMA custom-nya
    await queryInterface.removeIndex("Users", "idx_users_email");
    await queryInterface.removeIndex("Languages", "idx_languages_name");
    await queryInterface.removeIndex("Materials", "idx_materials_lang");
    await queryInterface.removeIndex("Materials", "idx_materials_order");
    await queryInterface.removeIndex("Quizzes", "idx_quizzes_lang");
    await queryInterface.removeIndex("Enrollments", "idx_enrollments_user_lang");
    await queryInterface.removeIndex("QuizHistories", "idx_quizhistories_user");
    await queryInterface.removeIndex("QuizHistories", "idx_leaderboard_latest");
    await queryInterface.removeIndex("QuizHistories", "idx_quizhistories_score");
  },
};

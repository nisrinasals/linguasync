'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.sequelize.query('DROP VIEW IF EXISTS view_leaderboard;');
    
    try {
      await queryInterface.removeIndex('QuizHistories', 'idx_leaderboard_latest');
    } catch (e) {
      console.log('Index might not exist, continuing...');
    }
    
    try {
      await queryInterface.renameColumn('QuizHistories', 'quiz_id', 'language_id');
    } catch (e) {
      console.log('Column rename skipped or already renamed...');
    }
    
    await queryInterface.addIndex('QuizHistories', ['user_id', 'language_id', 'createdAt'], {
      name: 'idx_leaderboard_latest'
    });
    
    await queryInterface.sequelize.query(`
      CREATE VIEW view_leaderboard AS
      SELECT 
          u.id AS user_id,
          u.username, 
          SUM(latest_attempts.score) AS total_point
      FROM users u
      JOIN (
          SELECT qh.user_id, qh.score
          FROM quizhistories qh
          WHERE qh.id IN (
              SELECT MAX(id) 
              FROM quizhistories 
              GROUP BY user_id, language_id
          )
      ) AS latest_attempts ON u.id = latest_attempts.user_id
      GROUP BY u.id
      ORDER BY total_point DESC;
    `);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.sequelize.query('DROP VIEW IF EXISTS view_leaderboard;');
    await queryInterface.removeIndex('QuizHistories', 'idx_leaderboard_latest');
    await queryInterface.renameColumn('QuizHistories', 'language_id', 'quiz_id');
  }
};

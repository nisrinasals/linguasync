'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
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
              GROUP BY user_id, quiz_id
          )
      ) AS latest_attempts ON u.id = latest_attempts.user_id
      GROUP BY u.id
      ORDER BY total_point DESC;
    `);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.sequelize.query('DROP VIEW IF EXISTS view_leaderboard;');
  }
};
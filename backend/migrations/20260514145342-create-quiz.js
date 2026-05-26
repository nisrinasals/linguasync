"use strict";
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable("Quizzes", {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER,
      },
      language_id: {
        allowNull: false,
        type: Sequelize.INTEGER,
        references: {
          model: "Languages",
          key: "id",
        },
        onUpdate: "CASCADE",
        onDelete: "CASCADE", 
      },
      question: {
        allowNull: false,
        type: Sequelize.TEXT,
      },
      option_a: {
        allowNull: false,
        type: Sequelize.STRING,
      },
      option_b: {
        allowNull: false,
        type: Sequelize.STRING,
      },
      option_c: {
        allowNull: false,
        type: Sequelize.STRING,
      },
      option_d: {
        allowNull: false,
        type: Sequelize.STRING,
      },
      correct_answer: {
        allowNull: false,
        type: Sequelize.ENUM("a", "b", "c", "d"),
      },
      duration: {
        allowNull: false,
        type: Sequelize.INTEGER,
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE,
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE,
      },
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable("Quizzes");
  },
};

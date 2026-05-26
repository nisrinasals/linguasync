"use strict";
const { Model } = require("sequelize");

module.exports = (sequelize, DataTypes) => {
  class Leaderboard extends Model {}

  Leaderboard.init(
    {
      user_id: DataTypes.INTEGER,
      username: DataTypes.STRING,
      total_point: DataTypes.INTEGER,
    },
    {
      sequelize,
      modelName: "Leaderboard",
      tableName: "v_leaderboard", // Merujuk ke View
      timestamps: false, // View tidak punya createdAt/updatedAt
      freezeTableName: true, // Jangan ubah nama tabel jadi jamak
    },
  );

  // Penting: Beri tahu Sequelize ini read-only
  Leaderboard.removeAttribute("id");

  return Leaderboard;
};

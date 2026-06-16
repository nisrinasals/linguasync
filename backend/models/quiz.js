"use strict";
const { Model } = require("sequelize");
module.exports = (sequelize, DataTypes) => {
  class Quiz extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      this.belongsTo(models.Language, { foreignKey: "language_id" });
    }
  }
  Quiz.init(
    {
      language_id: DataTypes.INTEGER,
      question: DataTypes.TEXT,
      option_a: DataTypes.STRING,
      option_b: DataTypes.STRING,
      option_c: DataTypes.STRING,
      option_d: DataTypes.STRING,
      correct_answer: DataTypes.STRING,
    },
    {
      sequelize,
      modelName: "Quiz",
    },
  );
  return Quiz;
};

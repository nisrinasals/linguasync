'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class QuizHistory extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      QuizHistory.belongsTo(models.User, { foreignKey: 'user_id' });
      QuizHistory.belongsTo(models.Quiz, { foreignKey: 'quiz_id' });
    }
  }
  QuizHistory.init({
    user_id: DataTypes.INTEGER,
    quiz_id: DataTypes.INTEGER,
    score: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'QuizHistory',
  });
  return QuizHistory;
};
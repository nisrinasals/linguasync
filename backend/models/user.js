"use strict";
const { Model } = require("sequelize");
module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      this.hasMany(models.Enrollment, { foreignKey: "user_id", onDelete: "CASCADE" });
      this.hasMany(models.QuizHistory, { foreignKey: "user_id", onDelete: "CASCADE" });
    }
  }
  User.init(
    {
      name: {
        type: DataTypes.STRING,
        field: "username",
      },
      email: DataTypes.STRING,
      password: DataTypes.STRING,
      role: DataTypes.STRING,
    },
    {
      sequelize,
      modelName: "User",
    },
  );
  return User;
};

"use strict";
const { Model } = require("sequelize");
module.exports = (sequelize, DataTypes) => {
  class Enrollment extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      this.belongsTo(models.User, { foreignKey: "user_id" });
      this.belongsTo(models.Language, { foreignKey: "language_id" });
    }
  }
  Enrollment.init(
    {
      user_id: DataTypes.INTEGER,
      language_id: DataTypes.INTEGER,
    },
    {
      sequelize,
      modelName: "Enrollment",
    },
  );
  return Enrollment;
};

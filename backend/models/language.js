"use strict";
const { Model } = require("sequelize");
module.exports = (sequelize, DataTypes) => {
  class Language extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      this.hasMany(models.Material, { foreignKey: "language_id", onDelete: "CASCADE" });
      this.hasMany(models.Quiz, { foreignKey: "language_id", onDelete: "CASCADE" });
      this.hasMany(models.Enrollment, { foreignKey: "language_id", onDelete: "CASCADE" });
    }
  }
  Language.init(
    {
      name: DataTypes.STRING,
      description: DataTypes.TEXT,
    },
    {
      sequelize,
      modelName: "Language",
    },
  );
  return Language;
};

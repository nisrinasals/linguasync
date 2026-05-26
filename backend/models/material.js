"use strict";
const { Model } = require("sequelize");
module.exports = (sequelize, DataTypes) => {
  class Material extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      this.belongsTo(models.Language, { foreignKey: "language_id" });
    }
  }
  Material.init(
    {
      language_id: DataTypes.INTEGER,
      title: DataTypes.STRING,
      content: DataTypes.TEXT,
      order_index: DataTypes.INTEGER,
    },
    {
      sequelize,
      modelName: "Material",
    },
  );
  return Material;
};

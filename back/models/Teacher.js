const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const teacherSchema = new mongoose.Schema({
  firstname: {
    type: String,
    required: true,
  },
  lastname: {
    type: String,
    required: true,
  },
  age: {
    type: Number,
    required: true,
  },
  email: {
    type: String,
    required: true,
  },
  promotion: [
    {
      type: Schema.Types.ObjectId,
      ref: "Promotion",
      required: false,
    },
  ],
});

module.exports = mongoose.model("Teacher", teacherSchema);

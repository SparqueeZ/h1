const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const studentSchema = new mongoose.Schema({
  user: {
    type: Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
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
  promotions: [
    {
      type: Schema.Types.ObjectId,
      ref: "Promotion",
    },
  ],
  lessons: [
    {
      type: Schema.Types.ObjectId,
      ref: "Lesson",
      required: false,
    },
  ],
});

module.exports = mongoose.model("Student", studentSchema);

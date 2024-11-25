const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const LessonSchema = new Schema({
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  date: {
    type: Date,
    required: true,
  },
  duration: {
    type: Number,
    required: true,
  },
  teachers: [
    {
      type: Schema.Types.ObjectId,
      ref: "Teacher",
      required: false,
    },
  ],
  students: [
    {
      type: Schema.Types.ObjectId,
      ref: "Student",
      required: false,
    },
  ],
  promotions: [
    {
      type: Schema.Types.ObjectId,
      ref: "Promotion",
      required: false,
    },
  ],
});

module.exports = mongoose.model("Lesson", LessonSchema);

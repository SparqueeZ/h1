const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const generateSessionToken = () => {
  const chars =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let token = "";
  for (let i = 0; i < 5; i++) {
    token += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return token;
};

const LessonSchema = new Schema({
  sessionToken: {
    type: String,
    required: true,
    unique: true,
    default: generateSessionToken,
  },
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
      student: {
        type: Schema.Types.ObjectId,
        ref: "Student",
        required: false,
      },
      isPresent: {
        type: Boolean,
        default: false,
      },
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

LessonSchema.methods.isTokenExpired = function () {
  const expirationTime = new Date(this.date);
  expirationTime.setMinutes(expirationTime.getMinutes() + this.duration);
  return new Date() > expirationTime;
};

module.exports = mongoose.model("Lesson", LessonSchema);

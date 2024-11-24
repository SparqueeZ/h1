const mongoose = require("mongoose");

const Schema = mongoose.Schema;

const studentSchema = new mongoose.Schema({
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
  class: {
    type: String,
    required,
  },
});

module.exports = mongoose.model("Student", studentSchema);

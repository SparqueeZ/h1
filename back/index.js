const express = require("express");
// const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const dbConfig = require("./config/db");
const http = require("http");
// const socketIo = require("socket.io");
// const cors = require("cors");
// const cookieParser = require("cookie-parser");
const teacherRoutes = require("./routes/teacherRoutes");

const app = express();
const port = process.env.PORT || 3000;

// Create HTTP server
const server = http.createServer(app);

// Middleware
// app.use(bodyParser.json());
// app.use(cookieParser());
// app.use(
//   cors({
//     origin: "http://172.16.81.224", // Permettre les requêtes de toutes les origines
//     credentials: true, // Enable credentials
//     methods: ["GET", "POST"],
//   })
// );

// app.use("/api/messages", messageRoutes);
// app.use("/api/rooms", roomRoutes);
// app.use("/api/users", userRoutes);

app.use("/api/teacher", teacherRoutes);

mongoose
  .connect(dbConfig.url, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log("Database connected"))
  .catch((err) => console.log("Database connection error:", err));

server.listen(port, "0.0.0.0", () => {
  console.log(`Server is running on port ${port}`);
});

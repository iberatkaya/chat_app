import express from "express";
import path from "path";
import cookieParser from "cookie-parser";
import logger from "morgan";
import socketio from "socket.io";
import * as uuid from "uuid";
import http from "http";
import cors from "cors";

var app = express();
var server = http.createServer(app);
const io = socketio(server);

app.use(cors());
app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "client", "public")));
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "client", "public", "index.html"));
});

app.get("/api/", function (req, res) {
  res.json({
    message: "API Endpoint",
  });
});

app.post("/api/create-room", function (req, res) {
  let roomId = uuid.v4();
  res.json({
    roomId: roomId,
  });
});

io.on("connection", (socket) => {
  console.log("user connected");
  socket.on("joinRoom", (roomId) => {
    socket.join(roomId);
    io.to(roomId).emit(
      "sendMessage",
      "Here is your room id: " + roomId + ". Send it to your friends to chat!"
    );
  });
  socket.on("sendMessage", (message, roomId) => {
    io.to(roomId).emit("sendMessage", message);
  });
});

const port = process.env.PORT || 5000;

server.listen(port);

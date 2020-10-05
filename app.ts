import express from "express";
import path from "path";
import cookieParser from "cookie-parser";
import logger from "morgan";
import socketio from "socket.io";
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

io.on("connection", (socket) => {
  socket.on("joinRoom", (roomId: string, username: string) => {
    console.log(roomId);
    console.log(username);
    socket.join(roomId);
    io.to(roomId).emit("sendMessage", username + " joined room " + roomId);
  });
  socket.on(
    "sendMessage",
    (message: string, roomId: string, username: string) => {
      io.to(roomId).emit("sendMessage", message, username);
    }
  );
});

const port = process.env.PORT || 5000;

server.listen(port);

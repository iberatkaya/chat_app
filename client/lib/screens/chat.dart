import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final bool joinRoom;
  final String joinRoomKey;
  const ChatPage({Key key, @required this.joinRoom, this.joinRoomKey})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController controller = ScrollController();
  GlobalKey<FormState> formKey;
  TextEditingController editingController = TextEditingController();
  IO.Socket socket;
  String theRoomId;
  List<String> messages = [];
  FocusNode messageNode;

  @override
  void initState() {
    messageNode = FocusNode();
    if (!widget.joinRoom)
      fetchRoomId().then((myRoomId) => initSocket(myRoomId));
    else
      initSocket(widget.joinRoomKey);
    super.initState();
  }

  @override
  void dispose() {
    messageNode.dispose();
    return super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (this.mounted) {
      return super.setState(fn);
    }
  }

  initSocket(String roomId) {
    try {
      theRoomId = roomId;
      socket = IO.io('https://ibkchatapp.herokuapp.com/#/', <String, dynamic>{
        'transports': ['websocket'],
      });
      socket.emit("joinRoom", roomId);
      socket.emit("sendMessage", ["test"]);
      print("inited socket");
      socket.on("sendMessage", (msg) {
        setState(() {
          messages.add(msg);
          controller.animateTo(controller.position.maxScrollExtent,
              duration: Duration(milliseconds: 200), curve: Curves.linear);
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> fetchRoomId() async {
    try {
      final res =
          await http.post("https://ibkchatapp.herokuapp.com/api/create-room");
      print(res.body);
      final bodyJson = jsonDecode(res.body);
      return bodyJson["roomId"];
    } catch (e) {
      print(e);
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: ListView.builder(
              controller: controller,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                if (index == 0 && messages[index].contains("id")) {
                  return ListTile(
                    title: RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          style: TextStyle(color: Colors.black),
                          text: messages[index]
                              .substring(0, messages[index].indexOf(": "))),
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => FlutterClipboard.copy(
                                    messages[index]
                                        .substring(
                                            messages[index].indexOf(": ") + 2,
                                            messages[index].indexOf(". "))
                                        .trim())
                                .then((value) => Fluttertoast.showToast(
                                    msg: "Copied to clipboard!")),
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w600),
                          text: messages[index].substring(
                              messages[index].indexOf(": "),
                              messages[index].indexOf(". "))),
                      TextSpan(
                          style: TextStyle(color: Colors.black),
                          text: messages[index]
                              .substring(messages[index].indexOf(". "))),
                    ])),
                  );
                }
                return ListTile(
                  title: SelectableText(messages[index]),
                );
              },
            ),
          ),
          Expanded(
            child: Form(
              key: formKey,
              child: TextFormField(
                focusNode: messageNode,
                onFieldSubmitted: (val) {
                  try {
                    socket.emit("sendMessage", [val, theRoomId]);
                    editingController.clear();
                    messageNode.requestFocus();
                  } catch (e) {
                    print(e);
                  }
                },
                controller: editingController,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: RaisedButton(
                child: Text("Send"),
                onPressed: () {
                  try {
                    socket.emit(
                        "sendMessage", [editingController.text, theRoomId]);
                    editingController.clear();
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

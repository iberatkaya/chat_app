import 'package:bubble/bubble.dart';
import 'package:client/domain/message/message.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String roomId;
  final String username;

  const ChatPage({Key key, this.roomId, this.username}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController controller = ScrollController();
  GlobalKey<FormState> formKey;
  TextEditingController messageController = TextEditingController();
  IO.Socket socket;
  String theRoomId;
  List<Message> messages = [];
  FocusNode messageNode;

  @override
  void initState() {
    messageNode = FocusNode();
    initSocket();
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

  void initSocket() {
    try {
      socket = IO.io('https://ibkchatapp.herokuapp.com/#/', <String, dynamic>{
        'transports': ['websocket'],
      });
      socket.emit("joinRoom", [widget.roomId, widget.username]);
      socket.on("sendMessage", (res) {
        Message msg = (res is String)
            ? Message(message: res, username: "Admin")
            : Message(message: res[0], username: res[1]);
        if (msg.username == widget.username) {
          return;
        }
        setState(() {
          messages.add(msg);
          controller.animateTo(controller.position.maxScrollExtent,
              duration: Duration(milliseconds: 100), curve: Curves.linear);
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void sendMessage() {
    try {
      socket.emit("sendMessage",
          [messageController.text, widget.roomId, widget.username]);
      Message msg =
          Message(message: messageController.text, username: widget.username);
      setState(() {
        messages.add(msg);
        controller.animateTo(controller.position.maxScrollExtent,
            duration: Duration(milliseconds: 100), curve: Curves.linear);
      });
      messageController.clear();
      messageNode.requestFocus();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: SelectableText(widget.roomId),),
      backgroundColor: Colors.blueGrey[50],
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: Container(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                controller: controller,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  if (message.username == widget.username) {
                    return Bubble(
                      margin: BubbleEdges.only(top: 8),
                      radius: Radius.circular(12),
                      alignment: Alignment.topRight,
                      nip: BubbleNip.rightTop,
                      elevation: 2,
                      color: Color.fromRGBO(225, 255, 199, 1.0),
                      child: SelectableText(message.message,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                  return Bubble(
                    margin: BubbleEdges.only(top: 8),
                    radius: Radius.circular(12),
                    alignment: Alignment.topLeft,
                    nip: BubbleNip.leftTop,
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.username, style: TextStyle(fontSize: 11, color: Colors.grey,), textAlign: TextAlign.left,),
                        SelectableText(message.message, 
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      focusNode: messageNode,
                      onFieldSubmitted: (val) {
                        sendMessage();
                      },
                      decoration: InputDecoration(
                        labelText: "Message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      controller: messageController,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.11,
                  child: RaisedButton(
                    child: Text("Send"),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.01,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

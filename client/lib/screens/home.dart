import 'package:client/screens/chat.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
        actions: [Icon(Icons.person_outline)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    joinRoom: false,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create Room",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.create_outlined),
                  )
                ],
              ),
            ),
            RaisedButton(
              onPressed: () async {
                try {
                  String res = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        TextEditingController controller =
                            TextEditingController();
                        return AlertDialog(
                          actions: [
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            FlatButton(
                                child: Text("Join"),
                                onPressed: () {
                                  print(controller.text);
                                  Navigator.of(context).pop(controller.text);
                                }),
                          ],
                          title: Text("Enter a Room ID"),
                          content: TextField(
                            controller: controller,
                          ),
                        );
                      });
                  if (res == null || res == "") return;
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatPage(
                            joinRoom: true,
                            joinRoomKey: res,
                          )));
                } catch (e) {
                  print(e);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Join Room",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.person_add_alt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

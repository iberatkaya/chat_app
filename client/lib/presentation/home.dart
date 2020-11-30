import 'package:client/presentation/chat.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Welcome To IBK Chat", style: TextStyle(fontSize: 28)),
            const SizedBox(height: 16),
            Text("Create or join a room and start talking!",
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 16),
            RaisedButton(
              onPressed: () async {
                try {
                  final res = await showDialog<Map<String, String>>(
                      context: context,
                      builder: (context) {
                        TextEditingController roomIdController =
                            TextEditingController();
                        TextEditingController nameController =
                            TextEditingController();
                        GlobalKey<FormState> formkey = GlobalKey<FormState>();
                        return AlertDialog(
                          actions: [
                            FlatButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            FlatButton(
                              child: Text("Join"),
                              onPressed: () {
                                if (formkey.currentState.validate()) {
                                  Navigator.of(context).pop({
                                    "roomId": roomIdController.text,
                                    "username": nameController.text
                                  });
                                }
                              },
                            ),
                          ],
                          title: Text(
                              "Enter a room name and username to join or create a room!"),
                          contentPadding: EdgeInsets.all(18),
                          content: Form(
                            key: formkey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: "Room Name",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val.length < 4) {
                                      return "Has to be longer than 3";
                                    }
                                    return null;
                                  },
                                  controller: roomIdController,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: "Username",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val.length < 4) {
                                      return "Has to be longer than 3";
                                    }
                                    return null;
                                  },
                                  controller: nameController,
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                  if (res == null) return;
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatPage(
                            roomId: res["roomId"],
                            username: res["username"],
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
                    "Enter A Room",
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

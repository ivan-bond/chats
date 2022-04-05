import 'package:chats/helperfunctions/sharedpref_helper.dart';
import 'package:chats/services/database.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;
  ChatScreen(this.chatWithUsername, this.name);

  /* static String returnMyName(ChatScreen c) {
    return c.name;
  } */

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String chatRoomId, messageId = "";
  late String myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEdittingController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;

    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername, widget.name);
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked) {
    if (messageTextEdittingController.text != "") {
      String message = messageTextEdittingController.text;
      late Map<String, dynamic> lastMessageInfoMap;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        lastMessageInfoMap = {
          "lastmessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName,
        };
      });

      DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

      if (sendClicked) {
        // remove the text in the message input field
        messageTextEdittingController.text = "";

        // make message id blank to get regenerated on next message send
        messageId = "";
      }
    }
  }

  getAndSetMessages() async {}

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreference();
    getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
          title: Text(
        widget.name,
        style: TextStyle(fontFamily: 'EBGaramond', fontWeight: FontWeight.bold),
      )),
      body: Container(
          child: Stack(
        children: [
          Container(
            alignment: Alignment(0, 0.95),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.black.withOpacity(0.5),
              ),
              child: Row(children: [
                Expanded(
                    child: TextField(
                  controller: messageTextEdittingController,
                  cursorColor: Colors.pink,
                  style: TextStyle(
                    fontFamily: 'EBGaramond',
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "type a message",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: 'EBGaramond',
                        fontSize: 20,
                      )),
                )),
                Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ]),
            ),
          )
        ],
      )),
    );
  }
}

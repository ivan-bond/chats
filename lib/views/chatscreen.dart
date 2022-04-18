import 'package:chats/helperfunctions/sharedpref_helper.dart';
import 'package:chats/services/database.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name, profileUrl;
  ChatScreen(this.chatWithUsername, this.name, this.profileUrl);

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
  Stream? messageStream;

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
      Map<String, dynamic> lastMessageInfoMap;

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

      DatabaseMethods().addMessage(chatRoomId, messageId, messageInfoMap);

      lastMessageInfoMap = {
        "lastmessage": message,
        "lastMessageSendTs": lastMessageTs,
        "lastMessageSendBy": myUserName,
      };

      DatabaseMethods().updateLastMessageSend(chatRoomId, lastMessageInfoMap);

      if (sendClicked) {
        // remove the text in the message input field
        messageTextEdittingController.text = "";

        // make message id blank to get regenerated on next message send
        messageId = "";
      }
    }
  }

  /* Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
        mainAxisAlignment:
            sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: sendByMe ? Colors.white70 : Colors.white54,
            ),
            padding: EdgeInsets.all(16),
            child: Text(
              message,
              textWidthBasis: TextWidthBasis.longestLine,
              style: TextStyle(
                  fontFamily: 'EBGaramond', fontWeight: FontWeight.bold),
            ),
          ),
        ]);
  } */

  Widget chatMessageTile(String message, bool sendByMe) {
    return SafeArea(
      child: Align(
        alignment: sendByMe ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: sendByMe
                ? Color.fromARGB(255, 96, 39, 176)
                : Color.fromARGB(255, 43, 43, 43),
          ),
          padding: EdgeInsets.all(16),
          child: Text(
            message,
            textWidthBasis: TextWidthBasis.longestLine,
            style: TextStyle(
                fontFamily: 'EBGaramond',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 90, top: 16),
                itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds =
                      (snapshot.data! as QuerySnapshot).docs[index];
                  return chatMessageTile(
                      ds["message"], myUserName == ds["sendBy"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

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
      backgroundColor: Colors.black,
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color.fromARGB(255, 43, 43, 43),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  widget.profileUrl,
                  height: 45,
                  width: 45,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  widget.name,
                  style: TextStyle(
                      fontFamily: 'EBGaramond',
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )
            ],
          )),
      body: Container(
          child: Stack(
        children: [
          chatMessages(),
          Container(
            alignment: Alignment(0, 0.95),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Color.fromARGB(255, 43, 43, 43),
              ),
              child: Row(children: [
                Expanded(
                    child: TextField(
                  controller: messageTextEdittingController,
                  onChanged: (value) {
                    addMessage(false);
                  },
                  cursorColor: Color.fromARGB(255, 96, 39, 176),
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
                GestureDetector(
                  onTap: () {
                    addMessage(true);
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ]),
            ),
          )
        ],
      )),
    );
  }
}

import 'package:chats/helperfunctions/sharedpref_helper.dart';
import 'package:chats/services/auth.dart';
import 'package:chats/services/database.dart';
import 'package:chats/views/chatscreen.dart';
import 'package:chats/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  //final String name;
  //Home(this.name);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  Stream? usersStream;
  late String myName, myProfilePic, myUserName, myEmail;

  TextEditingController searchUsernameEditingConroller =
      TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchButtonClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingConroller.text);
    setState(() {});
  }

  Widget searchListUserTile({String? email, name, profileUrl, username}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName!, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name, profileUrl)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 50,
              width: 50,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'EBGaramond',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                email!,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'EBGaramond',
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds =
                      (snapshot.data! as QuerySnapshot).docs[index];
                  return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomsList() {
    return Container();
  }

  @override
  void initState() {
    getMyInfoFromSharedPreference();
    super.initState();
  }

  String greeting() {
    var now = DateTime.now();
    int time = now.hour.toInt();

    if (time < 11 && time > 5) {
      return "Good Morning. 🌅";
    } else if (time > 11 && time < 18) {
      return "Have a nice day. 🌞";
    } else {
      return "Good night. 🌜";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 43, 43, 43),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 43, 43, 43),
        title: Text(
          greeting(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'EBGaramond',
              color: Colors.white),
        ),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
              child: Icon(Icons.exit_to_app, color: Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUsernameEditingConroller.text = "";
                          setState(() {});
                        },
                        child: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            )),
                      )
                    : Container(),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          cursorColor: Colors.pink,
                          controller: searchUsernameEditingConroller,
                          // ignore: prefer_const_constructors
                          style: TextStyle(
                            fontFamily: 'EBGaramond',
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          // ignore: prefer_const_constructors
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "username",
                              // ignore: prefer_const_constructors
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'EBGaramond',
                                fontSize: 20,
                              )),
                        )),
                        GestureDetector(
                            onTap: () {
                              if (searchUsernameEditingConroller.text != "") {
                                onSearchButtonClick();
                              }
                            },
                            // ignore: prefer_const_constructors
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : chatRoomsList()
          ],
        ),
      ),
    );
  }
}

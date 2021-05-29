import 'dart:ui';
import 'package:fling/EncryptionDecryptionClass.dart';
import 'package:fling/UserData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';

class ChatPage extends StatefulWidget {

  static String chatID;
  static String selectedUsername;
  static bool decryptionON=true;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageTextController = TextEditingController();
  CollectionReference reference = FirebaseFirestore.instance.collection('groupChats').doc(ChatPage.chatID).collection('chats');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[700],title: Text("${ChatPage.selectedUsername}",
        style: TextStyle(color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.w400),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(icon: Icon(Icons.fingerprint),onPressed: () {},),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StreamBuilder(
                stream: reference.orderBy('timeStamp',descending: false).snapshots(),
                builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){

                  if(snapshot.connectionState==ConnectionState.none){
                    return Center(child: Text("No internet Connection",style: TextStyle(color: Colors.black54,fontSize: 18.0),),);
                  }else if(snapshot.connectionState==ConnectionState.waiting){
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(child: CircularProgressIndicator())
                    );
                  }
                  if(snapshot.data.size==0){
                    return Container(
                      height: MediaQuery.of(context).size.height-140,
                        child: Center(child: Text("Nothing to show",style: TextStyle(color: Colors.black54,fontSize: 18.0),),)
                    );
                  }else{
                    return Container(
                      height: MediaQuery.of(context).size.height-140,
                      child: ListView.builder(
                          itemCount: snapshot.data.size,
                          itemBuilder: (context,index){
                            if(snapshot.data.docs[index].get('senderName')==RegisteredData.username){             //user itself
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width:MediaQuery.of(context).size.width/2,
                                    margin: EdgeInsets.only(top: 20.0,right: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[500],
                                          offset: Offset(3.0, 3.0),
                                          blurRadius: 15.0,
                                          spreadRadius: 1,
                                        ),
                                        BoxShadow(
                                            color: Colors.white,
                                            offset: Offset(-3.0, -3.0),
                                            blurRadius: 15.0,
                                            spreadRadius: 1
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(ChatPage.decryptionON?"${EncryptDecrypt.decryptMessage(snapshot.data.docs[index].get('messageContent'))}":"${snapshot.data.docs[index].get('messageContent')}"
                                      ,style: TextStyle(color: Colors.black,fontSize: 15),
                                    ),
                                  ),
                                ],
                              );
                            }else{
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width:MediaQuery.of(context).size.width/2,
                                    margin: EdgeInsets.only(top: 20.0,left: 10.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[500],
                                          offset: Offset(3.0, 3.0),
                                          blurRadius: 15.0,
                                          spreadRadius: 1,
                                        ),
                                        BoxShadow(
                                            color: Colors.white,
                                            offset: Offset(-3.0, -3.0),
                                            blurRadius: 15.0,
                                            spreadRadius: 1
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(ChatPage.decryptionON?"${EncryptDecrypt.decryptMessage(snapshot.data.docs[index].get('messageContent'))}":"${snapshot.data.docs[index].get('messageContent')}"
                                      ,style: TextStyle(color: Colors.black87,fontSize: 15),
                                    ),
                                  ),
                                ],
                              );
                            };
                          }),
                    );
                  }
                }
            ),

            Container(
                height: 60.0,
                margin: EdgeInsets.only(left: 5.0,right: 5.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: TextField(
                      controller: messageTextController,
                      decoration: InputDecoration(
                          hintText: "Enter message",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: IconButton(icon: Icon(Icons.send_rounded,color: Colors.white), onPressed: sendMessage),
                          )
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
            ),
          ],
        ),
      )
    );
  }

  Future sendMessage() async {
    String message = messageTextController.text.trim();
    print('actual message : ${message}');
    reference.doc(DateTime.now().millisecondsSinceEpoch.toString()).set({
      'senderName':'${RegisteredData.username}',
      'receiverName':'${ChatPage.selectedUsername}',
      'messageContent':'${EncryptDecrypt.encryptMessage(message)}',
      'timeStamp':'${DateTime.now().millisecondsSinceEpoch.toString()}'
    });
    messageTextController.clear();
  }


}
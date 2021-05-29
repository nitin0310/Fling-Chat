
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fling/Chat_Page.dart';
import 'package:fling/UserData.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  
  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
  TextEditingController searchController;
  Stream<QuerySnapshot> searchResultStream;
  List<Pair> list=[];

  @override
  void initState() {
    searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchAppBar(),
      body: StreamBuilder(
        stream: searchResultStream,
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){

          if(snapshot.connectionState==ConnectionState.none){
            return Center(child: Text("No internet Connection",style: TextStyle(color: Colors.black54,fontSize: 18.0),),);

          }else if(snapshot.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          if(snapshot.data.size==0){
            return Center(child: Text("Nothing to show",style: TextStyle(color: Colors.black54,fontSize: 18.0),),);
          }else{

            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context,int index){
                return GestureDetector(
                  onTap: (){
                    CollectionReference currentUserCollectionReference = FirebaseFirestore.instance.collection('users').doc(RegisteredData.uid).collection('chats');
                    CollectionReference collectionReference = FirebaseFirestore.instance.collection('groupChats');
                    bool alreadyHadConversation=false;

                    currentUserCollectionReference.get().then((querySnapshot) => querySnapshot.docs.forEach((element) {
                      if(element.data()['otherUserUID']==snapshot.data.docs[list.asMap()[index].index].id){
                        alreadyHadConversation=true;
                      }
                    })).whenComplete(() {
                      if(alreadyHadConversation){
                        print("conversation already exists------------------------");
                      }else{
                        print("conversation already not exists--------------------");

                        DocumentReference chatId = collectionReference.doc();
                        chatId.set({
                          'user1UID':'${RegisteredData.uid}',
                          'user1Username':'${RegisteredData.username}',
                          'user2UID':'${snapshot.data.docs[list.asMap()[index].index].id}',
                          'user2Username':'${snapshot.data.docs[list.asMap()[index].index].get('USERNAME')}',
                        });

                        currentUserCollectionReference.doc(chatId.id).set({
                          'decryptionON':true,
                          'otherUserUID':snapshot.data.docs[list.asMap()[index].index].id,
                          'otherUsername':snapshot.data.docs[list.asMap()[index].index].get('USERNAME'),
                        });

                        FirebaseFirestore.instance.collection('users').doc(snapshot.data.docs[list.asMap()[index].index].id).collection('chats').doc(chatId.id).set({
                          'decryptionON':true,
                          'otherUserUID':RegisteredData.uid,
                          'otherUsername':RegisteredData.username,
                        });

                        ChatPage.selectedUsername=snapshot.data.docs[list.asMap()[index].index].get('USERNAME').toString();
                        ChatPage.chatID=chatId.id.toString();

                        chatId.collection('chats');
                      }
                    });

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ChatPage()));
                  },



                  child: Container(
                    margin: EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0),
                    height: 70.0,
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Center(
                      child: Text(
                        snapshot.data.docs[list.asMap()[index].index].get('USERNAME'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget searchAppBar() {
  return AppBar(
    backgroundColor: Colors.black54,
    title: TextField(
      controller: searchController,
      cursorColor: Colors.white,
      cursorHeight: 25.0,
      style: TextStyle(color: Colors.white70,fontSize: 20.0),
      decoration: InputDecoration(
        hintText: "Search user",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70,fontSize: 20.0),
      ),
    ),
    actions: [
      Container(
        margin: EdgeInsets.only(right: 10.0),
        child: IconButton(
            icon: Icon(Icons.search,color: Colors.white,),
            onPressed: (){
            searchResults(searchController.text.trim());
            }
        ),
      )
    ],
  );
  }

  Future searchResults(String searchString) async {
    setState(() {

      searchResultStream = collectionReference.snapshots();
      if(searchString.length!=0){
        searchResultStream.forEach((element) {
          for(int i=0;i<element.size;i++){
            if(element.docs[i].get('USERNAME').toString().startsWith(searchString)){
              list.add(new Pair(element.docs[i].get('USERNAME').toString(),i));
            }
          }
        });
      }
    });
  }
}

class Pair{
  String name;
  int index;

  Pair(this.name,this.index);
}
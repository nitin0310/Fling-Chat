
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fling/Chat_Page.dart';
import 'package:fling/DeleteAccount.dart';
import 'package:fling/Search_Page.dart';
import 'package:fling/UserData.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class Dashboard extends StatefulWidget {

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users').doc(RegisteredData.uid).collection('chats');
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool userAuthenticated=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text("fling",style: TextStyle(color: Colors.white,fontSize: 18.0,fontWeight: FontWeight.w400),),
        ),
        actions: [
          IconButton(icon: Icon(Icons.delete_outline,color: Colors.white,),onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>DeleteAccount())),),
          IconButton(icon: Icon(Icons.logout), onPressed: ()=> logOut(),iconSize: 20.0,),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],child: Icon(Icons.search_rounded,color: Colors.white,),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchPage()));
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: collectionReference.snapshots(),
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
                itemCount: snapshot.data.size,
                itemBuilder: (context,int index){
                  return GestureDetector(
                    onTap: () async {
                      if(await _isBiometricAvailable()) {
                      await _getListOfBiometricTypes();
                      await _authenticateUser();
                      }

                      if(userAuthenticated){
                        ChatPage.chatID=snapshot.data.docs[index].id;
                        ChatPage.selectedUsername=snapshot.data.docs[index]['otherUsername'];
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatPage()));
                        userAuthenticated=false;
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                            height: 70,
                            width: ((MediaQuery.of(context).size.width*2)/3)+30,
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
                            child: Center(child: Text("${snapshot.data.docs[index]['otherUsername']}"),)
                        ),
                        
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(height: 10.0,),
                            Container(
                                child: Center(
                                    child: IconButton(icon: Icon(
                                        Icons.no_encryption_rounded,
                                        color: snapshot.data.docs[index]['decryptionON']?Colors.green:Colors.red[300],
                                    ),
                                      onPressed: (){
                                      showDialog(context: context, builder: (BuildContext context){
                                        return AlertDialog(
                                          title: Text("Status"),
                                          content: snapshot.data.docs[index]['decryptionON']?Text("Encryption Enabled"):Text("Encryption Disabled"),
                                        );
                                      });
                                      setState(() {
                                        if(snapshot.data.docs[index]['decryptionON']){
                                          collectionReference.doc(snapshot.data.docs[index].id).update({
                                            'decryptionON':false,
                                          }).whenComplete(() {
                                            ChatPage.decryptionON = false;
                                          });
                                        }else{
                                          collectionReference.doc(snapshot.data.docs[index].id).update({
                                            'decryptionON':true,
                                          }).whenComplete(() {
                                            ChatPage.decryptionON = true;
                                          });
                                        }
                                      });
                                      },
                                    )
                                ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.all(Radius.circular(25.0)),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                });
          }
        },
      ),
    );
  }

  Future logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("UID", "");
    preferences.setBool("LOGGEDIN", false);

    Navigator.of(context).pop();
  }

  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try {
      isAvailable = await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      print(e);
    }

    if (!mounted) return isAvailable;

    isAvailable
        ? print('Biometric is available!')
        : print('Biometric is unavailable.');

    return isAvailable;
  }


  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    }catch (e) {
      print(e);
    }

    if (!mounted) return;

    print(listOfBiometrics);
  }

  Future<void> _authenticateUser() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason:
        "Please authenticate to continue",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    }catch (e) {
      print(e);
    }

    if (!mounted) return;

    isAuthenticated ? print('User is authenticated!') : print('User is not authenticated.');

    userAuthenticated=isAuthenticated;
  }
}

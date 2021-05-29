import 'package:fling/SignUp_Page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteAccount extends StatefulWidget {
  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
        label: Text("Get back",style: TextStyle(color: Colors.white),),
        onPressed: ()=> Navigator.pop(context),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  children: [
                    Icon(Icons.account_circle,size: 160,color: Colors.black54,),
                    SizedBox(height: 20,),
                    Text("A step ahead to delete account"),
                    SizedBox(height: 20,),
                    Container(
                      margin: EdgeInsets.only(bottom: 80),
                      width: MediaQuery.of(context).size.width/2+90,
                      height: 50.0,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.all(Radius.circular(15))),
                        onPressed: ()=> deleteUser(),
                        color: Colors.redAccent,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Delete account ",style: TextStyle(color: Colors.white),),
                              Icon(Icons.delete,color: Colors.white,size: 19,)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future deleteUser() async{
    firebaseAuth.currentUser.delete();
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUp_Page()));
  }
}

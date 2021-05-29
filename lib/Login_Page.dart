import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fling/Dashboard.dart';
import 'package:fling/SignUp_Page.dart';
import 'package:fling/UserData.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login_Page extends StatefulWidget {
  @override
  _Login_PageState createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  String email;
  String password;
  String uid;
  TextEditingController emailController;
  TextEditingController passwordController;
  bool isLoading=false;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Login",style: TextStyle(color: Colors.white),),backgroundColor: Colors.blue[800],centerTitle: true,),
      body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.only(left: 20.0,right: 20.0,top: 40.0),
              height: 500,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Icon(Icons.security,size: 85,color: Colors.black54,),
                    ),
                    SizedBox(height: 30.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text("Enter email"),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: Colors.grey[800])
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: Colors.redAccent)
                          )
                      ),
                      validator: (value){
                        return !value.contains("@gmail.com")?'Invalid email! Please enter again':null;
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text("Enter password"),
                        ),
                      ],
                    ),
                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: Colors.grey[800])
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: Colors.redAccent)
                          )
                      ),
                      obscureText: true,
                      validator: (value){
                        return value.length<8?"Password should be atleast 8 characters":null;
                      },
                    ),

                    Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width*2/3+50,
                      margin: EdgeInsets.only(top: 20.0,right: 30.0,left: 30.0),
                      child: MaterialButton(
                          color: Colors.blue[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                          onPressed: ()=> validateUser(),
                          child: Center(child: Text("Login",style: TextStyle(color: Colors.white),),)
                      ),
                    ),

                    Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width*2/3+50,
                      margin: EdgeInsets.only(top: 20.0,right: 30.0,left: 30.0),
                      child: MaterialButton(
                          color: Colors.grey[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                          onPressed: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUp_Page())),
                          child: Center(child: Text("Sign Up here",style: TextStyle(color: Colors.white),),)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }

  void validateUser() {
    FormState state = formKey.currentState;
    if(state.validate()){
      print('Form is validated');
      loginUser();
    }else{
      print('Form is not validating');
    }
  }


  Future loginUser() async {
  this.email=emailController.text.trim();
  this.password=passwordController.text.trim();
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await firebaseAuth.signInWithEmailAndPassword(email: this.email, password: this.password).then((value) {
    print('logging time --- uid received : ${value.user.uid}');
    setState(() {
      RegisteredData.uid=value.user.uid;
      RegisteredData.email=value.user.email;
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
      collectionReference.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          if(element.id==RegisteredData.uid){
            RegisteredData.username=element.data()['USERNAME'];
          }
        });
      });

    });

  }).whenComplete(() {
    preferences.setString('UID', RegisteredData.uid);
    preferences.setBool('LOGGEDIN', true);

    print("preferences uid : ${preferences.getString('UID')}");
    print("preferences loggedIn : ${preferences.getBool('LOGGEDIN')}");

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard()));
  }).catchError((error){
    print(error.toString());
  });
  }
}

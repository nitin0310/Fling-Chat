import 'package:fling/Login_Page.dart';
import 'package:fling/UserData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fling/Dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUp_Page extends StatefulWidget {
  @override
  _SignUp_PageState createState() => _SignUp_PageState();
}

class _SignUp_PageState extends State<SignUp_Page> {

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  TextEditingController usernameController;
  TextEditingController emailController;
  TextEditingController passwordController;

  String email;
  String password;
  String username;

  final firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign up",style: TextStyle(color: Colors.white),),backgroundColor: Colors.blue[800],centerTitle: true,),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(left: 20.0,right: 20.0,top: 40.0),
            height: 550,
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
                        child: Text("Enter username"),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: usernameController,
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
                    validator: (valid){
                      return valid.length==0?"Enter a valid username":null;
                    },
                  ),
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
                    keyboardType: TextInputType.emailAddress,
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
                        ),
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
                        child: Center(child: Text("Sign up",style: TextStyle(color: Colors.white),),)
                    ),
                  ),

                  Container(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width*2/3+50,
                    margin: EdgeInsets.only(top: 20.0,right: 30.0,left: 30.0),
                    child: MaterialButton(
                        color: Colors.grey[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
                        onPressed: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login_Page())),
                        child: Center(child: Text("Login here",style: TextStyle(color: Colors.white),),)
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
      registerUser();
    }else{
      print('Form is not validating');
    }
  }

  Future registerUser() async {

    this.username=usernameController.text.trim();
    this.email=emailController.text.trim();
    this.password=passwordController.text.trim();

    UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: this.email, password: this.password);
    collectionReference.doc(userCredential.user.uid).set({
      'USERNAME':'${this.username}',
      'UID':'${userCredential.user.uid}',
      'EMAIL':'${userCredential.user.email}',
    });

    setState(() {
      RegisteredData.uid=userCredential.user.uid;
      RegisteredData.email=userCredential.user.email;
      RegisteredData.username=this.username;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString('UID', userCredential.user.uid);
    preferences.setBool('LOGGEDIN', true);

    print("preferences uid : ${preferences.getString('UID')}");
    print("preferences loggedIn : ${preferences.getBool('LOGGEDIN')}");

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Dashboard()));
  }
}

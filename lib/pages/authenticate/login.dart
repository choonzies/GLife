import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glife/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  bool isPasswordVisible = false;

  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      // Navigate to HomePage or any other page
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-email') {
          errorMessage = 'Please provide a valid email';
        } else {
          errorMessage = 'Incorrect Email or Password';
        }
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_controllerUsername.text).get();
      if (userDoc.exists) {
        throw FirebaseAuthException(code: 'username-already-in-use', message: 'Username is already taken');
      }
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      await _firestore.collection('users').doc(_controllerUsername.text).set({
        'email': _controllerEmail.text,
        'friends': [],
        'friendReqs': []
      });
      // Navigate to HomePage or any other page
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-email') {
        errorMessage = 'Please provide a valid email';
      } else if (e.code == 'username-already-in-use') {
        errorMessage = 'Username is already taken';
      } else {
        errorMessage = e.message ?? 'An error occurred';
      }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _logo(),
              const SizedBox(height: 20),
              _usernameOrNot(),
              const SizedBox(height: 20),
              _entryField('Email', _controllerEmail, false),
              const SizedBox(height: 20),
              _entryField('Password', _controllerPassword, true),
              const SizedBox(height: 20),
              _errorMessage(),
              const SizedBox(height: 20),
              _submitButton(),
              const SizedBox(height: 10),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Image.asset('assets/images/logo.jpeg', height: 150);
  }

  Widget _entryField(String title, TextEditingController controller, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.green[50],
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : errorMessage!, style: TextStyle(color: Colors.red));
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
          errorMessage = '';
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }

  Widget _usernameOrNot() {
    return isLogin ? const SizedBox(height: 10) : _entryField('Username', _controllerUsername, false);
  }
}
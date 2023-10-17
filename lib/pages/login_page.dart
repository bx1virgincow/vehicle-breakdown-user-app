import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onroadapp/pages/landing_page.dart';
import 'package:onroadapp/pages/register_page.dart';
import 'package:onroadapp/services/authservices.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //defining the controller
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //loading indicator initialization
  bool isLoading = false;

  //disposing controllers
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 50,
            horizontal: 12,
          ),
          margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //icon
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/icon/myicon.png'),
                )),
              ),
              //
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 10),
              //email field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  prefixIconColor: Colors.orange,
                ),
              ),
              const SizedBox(height: 10.0),

              //password field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  prefixIconColor: Colors.orange,
                ),
              ),
              const SizedBox(height: 10.0),

              //button container
              isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          //set loading indicator in motion
                          setState(() {
                            isLoading = true;
                          });
                          //validating the input fields
                          if (emailController.text == "" ||
                              passwordController.text == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('All Fields Are Required')),
                            );
                          } else {
                            User? user = await AuthService().login(
                                emailController.text,
                                passwordController.text,
                                context);
                            if (user != null) {
                              // ignore: use_build_context_synchronously
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LandingPage()),
                                  (route) => false);
                            }
                          }
                          //terminate loading indicator
                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 10.0),
              //Don't have an account section
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => RegisterScreen()));
                },
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

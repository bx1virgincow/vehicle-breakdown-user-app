import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onroadapp/pages/landing_page.dart';
import 'package:onroadapp/pages/login_page.dart';
import 'package:onroadapp/services/authservices.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //initializing controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPass = TextEditingController();

  //loading indicator
  bool isLoading = false;

  //disposing controller
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    contactController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPass.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 100,
            horizontal: 20,
          ),
          margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 25),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/icon/myicon.png'),
                  )),
                ),
                SizedBox(height: 10),
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 10),
                //name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    prefixIconColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10.0),
                //email textform field
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
                //contact
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    prefixIconColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10.0),
                //password textform field
                TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    prefixIconColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10.0),
                //confirm password textform field
                TextFormField(
                  obscureText: true,
                  controller: confirmPass,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    prefixIconColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10.0),

                //buttons
                isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            if (emailController.text == "" ||
                                passwordController.text == "" ||
                                nameController.text == "" ||
                                contactController.text == "" ||
                                confirmPass.text == "") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('All Fields Are Required')));
                            } else if (passwordController.text !=
                                confirmPass.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Password do not match')));
                            } else {
                              User? user = await AuthService().register(
                                  nameController.text,
                                  emailController.text,
                                  contactController.text,
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
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => LoginScreen()));
                  },
                  child: const Text('Already have an account? Login here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

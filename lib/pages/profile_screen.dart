import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onroadapp/components/drawer_widget.dart';
import 'package:onroadapp/models/user_model.dart';
import 'package:onroadapp/pages/login_page.dart';
import 'package:onroadapp/services/authservices.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  // function to make a request to firebase to get user data
  Future getCurrentUserData(final id) async {
    final data = FirebaseFirestore.instance
        .collection('usersCollection')
        .doc(id)
        .get()
        .then(
      (value) {
        return value;
      },
    );
    return data;
  }

//loding indicator
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getCurrentUserData(user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.white),
          ),
        ),
        drawer: DrawerWidget(
          name: '',
          email: '',
        ),
        body: FutureBuilder(
          future: getCurrentUserData(user!.uid),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('failed to get data'),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Please wait...'),
                      SizedBox(height: 10),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              UserData userdata = UserData.fromJson(snapshot.data);
              return Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 50.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage('https://picsum.photos/200/300'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextFormField(userdata.name, 'Full name'),
                    const SizedBox(height: 20),
                    _buildTextFormField(userdata.email, 'Email'),
                    const SizedBox(height: 20),
                    _buildTextFormField(userdata.phone, 'Contact'),
                    const SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await AuthService().logout();
                                // ignore: use_build_context_synchronously
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: const Text('Log Out'),
                            ),
                          ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  //form build
  Widget _buildTextFormField(
    String text,
    String labelText,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: ListTile(title: Text(text)),
    );
  }
}

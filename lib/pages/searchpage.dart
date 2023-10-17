import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onroadapp/components/drawer_widget.dart';
import 'package:onroadapp/models/service_model.dart';
import 'package:onroadapp/pages/detailscreen.dart';

class SearchServicePage extends StatefulWidget {
  const SearchServicePage({super.key});

  @override
  State<SearchServicePage> createState() => _SearchServicePageState();
}

class _SearchServicePageState extends State<SearchServicePage> {
  List<ServiceModel> model = [];

  // Textform field controller.
  TextEditingController searchController = TextEditingController();

  //instance of fireStore.
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // making search request.
  Future<void> searchReq(String searchValue) async {
    List<ServiceModel> tmp = [];
    // service personnels query.
    CollectionReference servicePersonnels =
        firebaseFirestore.collection('collectionPath');
    QuerySnapshot querySnapshot = await servicePersonnels.get();

    for (var element in querySnapshot.docs) {
      ServiceModel serviceModel = ServiceModel.fromJson(element);
      // print(RegExp(r"^" "$searchValue").hasMatch(serviceModel.service));
      if ((serviceModel.service)
          .toLowerCase()
          .contains(searchValue.toLowerCase())) {
        tmp.add(serviceModel);
        model = tmp;
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Locate Service'),
        ),
        drawer: DrawerWidget(
          name: '',
          email: '',
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Row(children: [
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.chevron_left),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: searchController,
                    onChanged: searchReq,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Find services",
                    ),
                  ),
                ),
              ),
            ]),
            Expanded(
                child: (model.isEmpty)
                    ? const Center(
                        child: const Text('Please search for a service'),
                      )
                    : ListView.builder(
                        itemCount: model.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return DetailScreen(
                                    serviceModel: model.elementAt(index));
                              }));
                            },
                            title: Text(model.elementAt(index).name),
                            subtitle: Text(model.elementAt(index).address),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        })),
          ]),
        ),
      ),
    );
  }
}

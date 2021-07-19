import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'contactModel.dart';
import 'createNewContactScreen.dart';
import 'updateContacts.dart';


Future<ContactModel> deleteContactData(String id) async {

  final http.Response response = await http.delete(
    Uri.parse('https://phonebookappapicloud.herokuapp.com/contacts/delete/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJ1c2VybmFtZSI6Imd1ZXN0IiwiZW1haWwiOiJndWVzdEBnbWFpbC5jb20ifSwiaWF0IjoxNjI2NjczMDY4fQ.LcNRdqaL2B3MwDUhAO0bZwzMxz2MGsl3Bhf3_CSlw4g',
    },
  );

  if (response.statusCode == 200) {
    return ContactModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to delete contact.');
  }
}

class DataFromAPI extends StatefulWidget {
  @override
  _DataFromAPIState createState() => _DataFromAPIState();
}

class _DataFromAPIState extends State<DataFromAPI> {
  List<Future<ContactModel>> futureContactData = <Future<ContactModel>>[];
  int contactsCount = 0;
  late Future<ContactModel> _dataModel;

  @override
  void initState(){
    super.initState();
    setState(() {
      getContactData();
    });
  }

  //get Contacts from DB
  Future getContactData() async{
    final response = await http.get(Uri.http('phonebookappapicloud.herokuapp.com', 'contacts'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJ1c2VybmFtZSI6Imd1ZXN0IiwiZW1haWwiOiJndWVzdEBnbWFpbC5jb20ifSwiaWF0IjoxNjI2NjczMDY4fQ.LcNRdqaL2B3MwDUhAO0bZwzMxz2MGsl3Bhf3_CSlw4g',
        }
    );
    final jsonData = jsonDecode(response.body);
    List<ContactModel> contactmodels = [];

    for (var u in jsonData){
      ContactModel data = ContactModel(phoneNumbers: u["phone_numbers"], id: u["_id"], lastName: u["last_name"], firstName: u["first_name"], v: u["__v"]);
      contactmodels.add(data);
    }

    if(response.statusCode == 200){
      print("Contact data taken from Database");
      print("Total contacts: ${contactmodels.length} ");
      return contactmodels;
    }else{
      print("Cannot get data");
    }
  }

  Widget phoneNumbersList(AsyncSnapshot<dynamic> snapshot,int index){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      verticalDirection: VerticalDirection.down,
      children: snapshot.data[index].phoneNumbers.map<Widget>((x) => Text(x, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Contacts", style: TextStyle(fontSize: 22),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewContact()));
              //Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeleteContactAndRefreshScreen()));
            },
            child: Icon(Icons.person_add_alt, color: Colors.black),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh list',
            onPressed: () {
              setState(() {
                getContactData();
              });
            },
          ),
        ],
      ),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Container(
              child: FutureBuilder(
                future: getContactData(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
                  if(snapshot.data == null){
                    return Container(
                      child: Center(
                        child: Text('Loading...'),
                      ),
                    );
                  }else
                    return ListView.builder(itemCount: snapshot.data.length,
                        itemBuilder: (context, index){
                          return Dismissible(
                            direction: DismissDirection.endToStart,
                            key: Key(snapshot.data[index].id),
                            onDismissed: (direction) {
                              String contactName = (snapshot.data[index].firstName.toString() + ' ' + snapshot.data[index].lastName.toString());
                              deleteContactData(snapshot.data[index].id);
                              setState(() {
                                snapshot.data.removeAt(index);
                              });
                              // Then show a snackbar.
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Contact: $contactName deleted')));
                            },
                            //confirmation
                            confirmDismiss: (DismissDirection direction) async{
                              return await showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  title: const Text("Are you sure?"),
                                  content: const Text('Do you really want to delete this contact? This process cannot be undone.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: (){
                                          Navigator.of(context).pop(true);
                                          setState(() {
                                            getContactData();
                                          });
                                        },
                                        child: const Text('Delete'))
                                  ],
                                );
                              });
                            },
                            // Show a red background as the item is swiped away.
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              color: Colors.red,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                child: Icon(Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateContactPage(id: snapshot.data[index].id.toString())));
                              },
                              child: Card(
                                margin: EdgeInsets.only(top: 5, bottom: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          SizedBox(width: 8.0),
                                          CircleAvatar(
                                            backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                            radius: 30.0,
                                            child: Text(snapshot.data[index].firstName[0] + snapshot.data[index].lastName[0],
                                                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                          SizedBox(width: 18.0),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,  verticalDirection: VerticalDirection.down,
                                            children: [
                                              Text(snapshot.data[index].firstName + ' ' + snapshot.data[index].lastName,
                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                color: Colors.black,
                                                height: 1.5,
                                                width: 230,
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                verticalDirection: VerticalDirection.down,
                                                children: [
                                                  Text("Phone Numbers: ",
                                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                  ),
                                                  SizedBox(width: 5),
                                                  phoneNumbersList(snapshot, index),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                },
              ),
            ),
          )
      ),
    );
  }
}
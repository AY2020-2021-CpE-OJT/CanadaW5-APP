import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'contactModel.dart';
import 'main.dart';

Future<ContactModel?> updateContact(List<dynamic> phone_numbers, String id, String last_name, String first_name) async{
  final response = await http.patch(
    Uri.parse('https://phonebookappapicloud.herokuapp.com/contacts/update/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJ1c2VybmFtZSI6Imd1ZXN0IiwiZW1haWwiOiJndWVzdEBnbWFpbC5jb20ifSwiaWF0IjoxNjI2NjczMDY4fQ.LcNRdqaL2B3MwDUhAO0bZwzMxz2MGsl3Bhf3_CSlw4g',
    },
      body: jsonEncode(<dynamic, dynamic>
      {"last_name": last_name, "first_name": first_name, "phone_numbers": phone_numbers}));

  if (response.statusCode == 200) {
    return ContactModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update contact.');
  }
}

Future<ContactModel?> getSpecificContact(String id) async{
  final response = await http.get(Uri.parse('https://phonebookappapicloud.herokuapp.com/contacts/find/' + id),
  headers: {
    HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJ1c2VybmFtZSI6Imd1ZXN0IiwiZW1haWwiOiJndWVzdEBnbWFpbC5jb20ifSwiaWF0IjoxNjI2NjczMDY4fQ.LcNRdqaL2B3MwDUhAO0bZwzMxz2MGsl3Bhf3_CSlw4g',
  });
  final jsonData = jsonDecode(response.body);

  if(response.statusCode == 200){
    print("Specific Contact data taken from Database");
    return ContactModel.fromJson(jsonData);
  }else{
    print("Cannot get data");
  }
}

class UpdateContactPage extends StatefulWidget{
  final String id;
  UpdateContactPage({Key? key, required this.id}) : super(key: key);

  @override
  _UpdateContactPageState createState() => _UpdateContactPageState();
}

class _UpdateContactPageState extends State<UpdateContactPage>{
  int totalNumberFields = 0;
  int newContactField = 0;
  int pNumCounter = 0;
  late TextEditingController fnEditController;
  late TextEditingController lnEditController;
  List<TextEditingController> numbersEditController = [];

  late Future<ContactModel?> _newContactModel;

  void addNumberField() {
    setState(() {
      numbersEditController.insert(totalNumberFields, TextEditingController()); //add data
      newContactField++; //increment
    });
  }
  void deleteNumberField(index) {
    setState(() {
      newContactField--;
      numbersEditController.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _newContactModel = getSpecificContact(widget.id);
  }

  Future<void> saveNewContact() async {
    List<String> phoneNumbers = <String>[];
    for(int i = 0; i < totalNumberFields; i++){
      phoneNumbers.add(numbersEditController[i].text);
      numbersEditController[i].clear();
    }
    setState(() {
      _newContactModel = updateContact(phoneNumbers, widget.id, lnEditController.text, fnEditController.text);
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => FirstScreen()), (route) => false);
    });

    final message = 'Save Successful';
    final snackBar = SnackBar(
      content: Text(
        message, style:  TextStyle(fontSize: 15),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    //reset contents
    fnEditController.clear();
    lnEditController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Contact"),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),
            ),
            onPressed: (){
              saveNewContact();
            },
          )
        ],
      ),
      body: Container(
        child: FutureBuilder<ContactModel?>(
          future: _newContactModel,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              if (snapshot.hasError) {
                return Container(
                  child: Center(
                    child: Text('Unable to get contact'),
                  ),
                );
              } else if (snapshot.hasData) {
                totalNumberFields = snapshot.data!.phoneNumbers.length + newContactField;
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      Text("First name:                                                                                          ",),
                      TextFormField(
                        controller: fnEditController = TextEditingController(text: snapshot.data!.firstName),
                        decoration: InputDecoration(
                          //hintText: snapshot.data!.firstName.toString(),
                          suffixIcon: fnEditController.text.isEmpty
                              ? Container(
                                  width: 0,
                                )
                              : IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => fnEditController.clear(),
                                ),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 10),
                      Text("Last name:                                                                                           ",),
                      TextFormField(
                        controller: lnEditController = TextEditingController(text: snapshot.data!.lastName),
                        decoration: InputDecoration(
                          suffixIcon: fnEditController.text.isEmpty
                              ? Container(
                            width: 0,
                          )
                              : IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => lnEditController.clear(),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text("Phone numbers: ", style: TextStyle(fontSize: 20),),
                          SizedBox(width: 160),
                          ButtonTheme(
                              minWidth: 50,
                              height: 30,
                              child: ElevatedButton(
                                  child: Text('Add', style: TextStyle(fontSize: 15.0),),
                                  onPressed: addNumberField)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Flexible(
                        child: ListView.builder(
                            itemCount: totalNumberFields,
                            itemBuilder: (context, index){
                              if(pNumCounter < snapshot.data!.phoneNumbers.length){
                                for(int i = 0; i <= snapshot.data!.phoneNumbers.length; i++){
                                  numbersEditController.add(TextEditingController(text: snapshot.data!.phoneNumbers[pNumCounter]));
                                  pNumCounter++;
                                  return Row(
                                    children: [
                                      Flexible(
                                        flex: 8,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: TextFormField(
                                            controller: numbersEditController[index],
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.phone, color: Colors.black),
                                              hintText: snapshot.data!.phoneNumbers[index].toString(),
                                              border: OutlineInputBorder(),
                                            ),
                                            keyboardType: TextInputType.number,
                                            textInputAction: TextInputAction.done,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: IconButton(
                                            onPressed: (){
                                              deleteNumberField(index);
                                            },
                                            icon: const Icon(Icons.close), splashRadius: 2),
                                      ),
                                    ],
                                  );
                                }
                              } else {
                                numbersEditController.add(TextEditingController());
                                return Row(
                                  children: [
                                    Flexible(
                                      flex: 8,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextFormField(
                                          controller: numbersEditController[index],
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.phone, color: Colors.black),
                                            hintText: "0",
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: (){
                                            deleteNumberField(index);
                                          },
                                          icon: const Icon(Icons.close), splashRadius: 2),
                                    ),
                                  ],
                                );
                              }
                              throw ('Error');
                        }),
                      )
                    ],
                  ),
                );
              }
            }
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Getting Contact Data")
              ],
            ),
          );
          },
        )
      ),
    );
  }
}
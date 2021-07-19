import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'contactModel.dart';

class NewContact extends StatefulWidget {

  @override
  _NewContactState createState() => _NewContactState();
}

Future<ContactModel?> passData(String last_name, String first_name, List<dynamic> phone_numbers) async{
  final String URL = "phonebookappapicloud.herokuapp.com";
  final response = await http.post(Uri.http(URL, 'contacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjoxLCJ1c2VybmFtZSI6Imd1ZXN0IiwiZW1haWwiOiJndWVzdEBnbWFpbC5jb20ifSwiaWF0IjoxNjI2NjczMDY4fQ.LcNRdqaL2B3MwDUhAO0bZwzMxz2MGsl3Bhf3_CSlw4g',
      },
      body: jsonEncode(<dynamic, dynamic>
      {"last_name": last_name, "first_name": first_name, "phone_numbers": phone_numbers}));
  var cData = response.body;
  print(cData);

  if(response.statusCode == 201){
    return ContactModel.fromJson(jsonDecode(response.body));
  }else {
    print("Cannot save");
  }
}

class _NewContactState extends State<NewContact> {
  int numbersFieldCount = 1;
  final formKey = GlobalKey<FormState>();
  final fnController = TextEditingController();
  final lnController = TextEditingController();
  List<TextEditingController> numberController = [];
  late Future<ContactModel?> _dataModel;

  @override
  void initState() {
    super.initState();
    fnController.addListener(() => setState(() {}));
    lnController.addListener(() => setState(() {}));
  }

  //Control multiple phone numbers
  void addNumberField() {
    setState(() {
      numberController.insert(numbersFieldCount, TextEditingController()); //add data
      numbersFieldCount++; //increment
    });
  }
  void deleteNumberField(index) {
    setState(() {
      numbersFieldCount--;
      numberController.removeAt(index);
    });
  }

  void nothingToSave(){
    final message = 'Nothing to save';
    final snackBar = SnackBar(
      content: Text(
        message, style:  TextStyle(fontSize: 15),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> saveNewContact() async {
    if (fnController.text.isEmpty && lnController.text.isEmpty){
      nothingToSave();
    }else{
      List<String> phoneNumbers = <String>[];
      //reverse since it acts as a stack
      for(int i = numbersFieldCount-1; i >= 0; i--){
        phoneNumbers.add(numberController[i].text);
        numberController[i].clear();
      }

      setState(() {
        _dataModel = passData(lnController.text, fnController.text, phoneNumbers);
        numbersFieldCount = 1;
        FocusScope.of(context).requestFocus(FocusNode());
      });

      final message = 'Added to contacts';
      final snackBar = SnackBar(
        content: Text(
          message, style:  TextStyle(fontSize: 15),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      //reset contents
      fnController.clear();
      lnController.clear();
    }
  }

  //FIRST NAME
  Widget buildFirstName() => TextFormField(
    controller: fnController,
    decoration: InputDecoration(
      labelText: 'First Name',
      suffixIcon:fnController.text.isEmpty ?  Container(width: 0,): IconButton(
        icon: Icon(Icons.close),
        onPressed: () => fnController.clear(),
      ),
      border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.name,
    textInputAction: TextInputAction.done,
  );

  //LAST NAME
  Widget buildLastName() => TextFormField(
    controller: lnController,
    decoration: InputDecoration(
      labelText: 'Last Name',
      suffixIcon:lnController.text.isEmpty ?  Container(width: 0,): IconButton(
        icon: Icon(Icons.close),
        onPressed: () => lnController.clear(),
      ),
      border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.name,
    textInputAction: TextInputAction.done,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Contact", style: TextStyle(color: Colors.black, fontSize: 20),),
        centerTitle: true,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          //key: formKey,
          child: Column(
            children: [
              Icon(Icons.account_box_rounded, size: 100.0),
              SizedBox(height: 5),
              buildFirstName(),
              SizedBox(height: 10),
              buildLastName(),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(' Phone Numbers: ', style: TextStyle(fontSize: 16)),),
                  SizedBox(width: 60),
                  ButtonTheme(
                      minWidth: 50,
                      height: 30,
                      child: ElevatedButton(
                          child: Text('Add', style: TextStyle(fontSize: 15.0),),
                          onPressed: addNumberField))
                ],
              ),
              Flexible(
                child: ListView.builder(
                    itemCount: numbersFieldCount, itemBuilder: (context, index){
                   numberController.add(TextEditingController());
                    return Row(
                      children: [
                        Flexible(
                          flex: 10,
                          child:
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              controller: numberController[index],
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.phone, color: Colors.black),
                                labelText: "Phone number #${index + 1}:",
                                hintText: "0",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: (){
                              deleteNumberField(index);
                            },
                            icon: const Icon(Icons.close), splashRadius: 2,
                        ),
                      ],
                    );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
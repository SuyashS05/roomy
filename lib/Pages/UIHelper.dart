import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UIHelper{

  TextFieldHelper(TextEditingController controllertext,String texthint,String textlabel){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controllertext,
        decoration: InputDecoration(
            labelText: textlabel,
            hintText: texthint,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20)
            )
        ),
      ),
    );
  }

  ButtonHelper(String name,VoidCallback callbackfunc){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(onPressed: (){
          callbackfunc();
        },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,foregroundColor: Colors.white),
            child: Text(name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),)),
      ),
    );
  }
}
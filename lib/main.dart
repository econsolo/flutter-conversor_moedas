import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=6509ef29";

void main() {

  runApp(new MaterialApp(
    home: new Home(),
    theme: new ThemeData(
      hintColor: Colors.purple,
      primaryColor: Colors.purpleAccent
    ),
  ));
}

Future<Map> getDados() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = new TextEditingController();
  final dolarController = new TextEditingController();
  final euroController = new TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Conversor de Moedas"),
        backgroundColor: Colors.purple,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.refresh),
            onPressed: () {
              realController.text = "";
              dolarController.text = "";
              euroController.text = "";
            }
          )
        ],
      ),
      body: new FutureBuilder<Map>(
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return new Center(
                child: new Text("Carregando dados...",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    color: Colors.black,
                    fontSize: 25
                  )
                ),
              );
            default:
              if (snapshot.hasError) {
                return new Center(
                  child: new Text("Erro ao recuperar dados :(",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          color: Colors.redAccent,
                          fontSize: 40
                      )
                  ),
                );
              } else {

                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return new SingleChildScrollView(
                  padding: EdgeInsets.all(15),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new Icon(Icons.monetization_on,
                        size: 150,
                        color: Colors.purple,
                      ),
                      buildTextField("Real", "R\$", realController, _realChanged),
                      new Divider(),
                      buildTextField("Dólar", "U\$", dolarController, _dolarChanged),
                      new Divider(),
                      buildTextField("Euro", "€", euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
        future: getDados(),
      ),
    );
  }
}

Widget buildTextField(String label, String prefixo, TextEditingController controller,
    Function changed) {
  return new TextField(
    controller: controller,
    onChanged: changed,
    keyboardType: TextInputType.number,
    decoration: new InputDecoration(
        labelText: label,
        labelStyle: new TextStyle(
            color: Colors.black
        ),
        border: new OutlineInputBorder(),
        prefixText: "$prefixo "
    ),
    style: new TextStyle(
        color: Colors.black,
        fontSize: 25
    ),
  );
}

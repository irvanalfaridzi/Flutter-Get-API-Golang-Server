import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_api_golang_http/products.dart';
import 'dart:convert' as convert;

void main() {
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double fetchCountPercentage = 40.0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("Get API Golang Server with http package"),
          ),
          body: SizedBox.expand(
            child: Stack(
              children: [
                FutureBuilder(
                    future: fetchFromServer(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "${snapshot.error}",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: ListTile(
                                  title: Text(snapshot.data[index].name),
                                  subtitle: Text(
                                      "Count: ${snapshot.data[index].count} \t Price: ${snapshot.data[index].price}"),
                                ),
                              );
                            });
                      }
                    }),
                Positioned(
                    bottom: 5,
                    right: 5,
                    child: Slider(
                        value: fetchCountPercentage,
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label: fetchCountPercentage.toString(),
                        onChanged: (double value) {
                          setState(() {
                            fetchCountPercentage = value;
                          });
                        }))
              ],
            ),
          )),
    );
  }

  Future<List<Product>> fetchFromServer() async {
    var url = 'http://192.168.1.30:5500/products/$fetchCountPercentage';
    var response = await http.get(url);

    List<Product> productList = [];
    if (response.statusCode == 200) {
      var productMap = convert.jsonDecode(response.body);
      for (final item in productMap) {
        productList.add(Product.fromJson(item));
      }
    } else {
      print("Error");
    }
    return productList;
  }
}

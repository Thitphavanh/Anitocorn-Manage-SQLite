import 'package:flutter/material.dart';
import 'package:flutter_manage_sqlite/models/product_model.dart';

import 'providers/database_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manage SQLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _refresh = GlobalKey<RefreshIndicatorState>();
  DataBaseProvider? dataBaseProvider;

  @override
  void initState() {
    dataBaseProvider = DataBaseProvider();
    super.initState();
  }

  @override
  void dispose() {
    dataBaseProvider!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[700],
        child: const Icon(
          Icons.add,
        ),
        onPressed: () {
          createDialog();
        },
      ),
    );
  }

  _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      centerTitle: true,
      elevation: 0,
      title: const Text('Manage SQLite'),
      actions: [
        IconButton(
          onPressed: () {
            _refresh.currentState!.show();
            dataBaseProvider!.deleteAll();
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  _buildContent() {
    return RefreshIndicator(
      key: _refresh,
      onRefresh: () async {
        await Future.delayed(
          const Duration(seconds: 2),
        );
        setState(() {});
      },
      child: FutureBuilder(
        future: dataBaseProvider!.getProducts(),
        builder: (context, snapshot) {
          print(snapshot.hasData);
          if (snapshot.hasData) {
            List<ProductModel>? productModels = snapshot.data;
            if (productModels!.isNotEmpty) {
              return _buildListView(productModels.reversed.toList());
            }
            return const Center(
              child: Text('NO DATA'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  _buildListView(List<ProductModel> productModel) {
    return ListView.builder(
      itemCount: productModel.length,
      itemBuilder: (BuildContext context, position) {
        ProductModel item = productModel[position];
        return ListTile(
          leading: IconButton(
            onPressed: () {
              editDialog(item);
            },
            icon: Icon(
              Icons.list,
              color: Colors.blue[700],
            ),
          ),
          title: Text("${item.name}"),
          trailing: IconButton(
            onPressed: () async {
              _refresh.currentState!.show();
              dataBaseProvider!.deleteProduct(item.id!);
              await Future.delayed(const Duration(seconds: 2));
              final snackBar = SnackBar(
                content: const Text('Item deleted'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    _refresh.currentState?.show();
                    dataBaseProvider!.insertProduct(item).then(
                      (value) {
                        print(productModel);
                      },
                    );
                  },
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            icon: const Icon(
              Icons.clear,
              color: Colors.deepOrange,
            ),
          ),
          subtitle: Text("price: ${item.price} LAK, instock: (${item.stock})"),
        );
      },
    );
  }

  _buildBody() {
    return FutureBuilder(
      future: dataBaseProvider!.initDatabase(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildContent();
        }
        return Center(
          child: snapshot.hasError
              ? Text(snapshot.error.toString())
              : const CircularProgressIndicator(),
        );
      },
    );
  }

  createDialog() {
    var formKey = GlobalKey<FormState>();
    ProductModel productModel = ProductModel();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(hintText: "name"),
                  onSaved: (value) {
                    productModel.name = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: "price"),
                  onSaved: (value) {
                    productModel.price = double.parse(value!);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: "stock"),
                  onSaved: (value) {
                    productModel.stock = int.parse(value!);
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Submit"),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState?.save();
                        _refresh.currentState?.show();
                        Navigator.pop(context);
                        dataBaseProvider!.insertProduct(productModel).then(
                          (value) {
                            print(productModel);
                          },
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  editDialog(ProductModel productModel) {
    var formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: productModel.name,
                  decoration: const InputDecoration(hintText: "name"),
                  onSaved: (value) {
                    productModel.name = value;
                  },
                ),
                TextFormField(
                  initialValue: productModel.price.toString(),
                  decoration: const InputDecoration(hintText: "price"),
                  onSaved: (value) {
                    productModel.price = double.parse(value!);
                  },
                ),
                TextFormField(
                  initialValue: productModel.stock.toString(),
                  decoration: const InputDecoration(hintText: "stock"),
                  onSaved: (value) {
                    productModel.stock = int.parse(value!);
                  },
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Submit"),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState?.save();
                        _refresh.currentState?.show();
                        Navigator.pop(context);
                        dataBaseProvider!.updateProduct(productModel).then(
                          (row) {
                            print(row.toString());
                          },
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// SQLite Workshop EP.6
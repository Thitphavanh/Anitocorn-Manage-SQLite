import 'dart:io';

import 'package:flutter_manage_sqlite/models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseProvider {
  Database? database;

  Future<bool> initDatabase() async {
    try {
      String databaseName = 'ManageDB.db';
      final String databasePath = await getDatabasesPath();
      final String path = join(databasePath, databaseName);

      if (await Directory(dirname(path)).exists()) {
        await Directory(dirname(path)).create(recursive: true);
      }

      database = await openDatabase(
        path,
        version: 2,
        onCreate: (Database db, int version) async {
          print('Database Create');
          String sql = "CREATE TABLE $tableProduct("
              "$columnId INTEGER PRIMARY KEY,"
              "$columnName TEXT,"
              "$columnStock INTEGER ,"
              "$columnPrice REAL"
              ")";

          await db.execute(sql);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          print('Database oldVersion: $oldVersion, newVersion $newVersion');
          String sql = "CREATE TABLE SHOP("
              "id INTEGER PRIMARY KEY,"
              "name TEXT"
              ")";

          await db.execute(sql);
        },
        onOpen: (Database db) async {
          print('Database version: ${await db.getVersion()}');
        },
      );
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future close() async => database!.close();

  Future<List<ProductModel>> getProducts() async {
    List<Map> maps = await database!.query(
      tableProduct,
      columns: [columnId, columnName, columnPrice, columnStock],
    );

    if (maps.isNotEmpty) {
      return maps.map((p) => ProductModel.fromMap(p)).toList();
    }
    return [];
  }

  Future<ProductModel> getProduct(int id) async {
    List<Map> maps = await database!.query(
      tableProduct,
      columns: [columnId, columnName, columnPrice, columnStock],
      where: "$columnId = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProductModel.fromMap(maps.first);
    }
    return null!;
  }

  Future<ProductModel> insertProduct(ProductModel productModel) async {
    productModel.id =
        await database!.insert(tableProduct, productModel.toMap());

    return productModel;
  }

  Future<int> updateProduct(ProductModel productModel) async {
    print(productModel.id);
    return await database!.update(
      tableProduct,
      productModel.toMap(),
      where: "$columnId = ?",
      whereArgs: [productModel.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    return await database!.delete(
      tableProduct,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    String sql = "Delete from $tableProduct";
    await database!.rawDelete(sql);
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
const String tableProduct = 'product';
const String columnId = 'id';
const String columnName = 'name';
const String columnPrice = 'price';
const String columnStock = 'stock';

class ProductModel {
  int? id;
  String? name;
  double? price;
  int? stock;
  ProductModel();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnPrice: price,
      columnStock: stock,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  ProductModel.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    price = map[columnPrice];
    stock = map[columnStock];
  }
  

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, stock: $stock)';
  }
}

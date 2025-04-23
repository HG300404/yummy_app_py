class FirebaseModel {
  final Customer customer;
  final String status;
  final int total;
  final int order_id;
  final int res_id;
  final List<Dish> dishes;

  const FirebaseModel({
    required this.customer,
    required this.status,
    required this.total,
    required this.order_id,
    required this.res_id,
    required this.dishes,
  });

  Map<String, Object?> toMap() {
    return {
      'customer': customer.toMap(),
      'status': status,
      'total': total,
      'order_id': order_id,
      'res_id': res_id,
      'dishes': dishes.map((item) => item.toMap()).toList(),
    };
  }

  FirebaseModel.fromMap(Map<String, dynamic> map)
      : customer = Customer.fromMap(map['customer'] as Map<String, dynamic>),
        status = map['status'] ?? '',
        total = map['total'] ?? 0,
        order_id = map['order_id'] ?? 0,
        res_id = map['res_id'] ?? 0,
        dishes = List<Dish>.from(
          (map['dishes'] as List).map(
                (item) => Dish.fromMap(item as Map<String, dynamic>),
          ),
        );

  @override
  String toString() {
    return 'FirebaseModel(order_id: $order_id, customer: $customer, status: $status, total: $total, res_id: $res_id, dishes: $dishes)';
  }
}

class Customer {
  final String name;
  final String address;
  final int cus_id;

  const Customer({
    required this.name,
    required this.address,
    required this.cus_id,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'address': address,
      'cus_id': cus_id,
    };
  }

  Customer.fromMap(Map<String, dynamic> map)
      : name = map['name'] ?? '',
        address = map['address'] ?? '',
        cus_id = map['cus_id'] ?? 0;
}

class Dish {
  final String name;
  final String options;
  final int price;
  final int quantity;

  const Dish({
    required this.name,
    required this.options,
    required this.price,
    required this.quantity,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'options': options,
      'price': price,
      'quantity': quantity,
    };
  }

  Dish.fromMap(Map<String, dynamic> map)
      : name = map['name'] ?? '',
        options = map['options'] ?? '',
        price = map['price'] ?? 0,
        quantity = map['quantity'] ?? 0;
}
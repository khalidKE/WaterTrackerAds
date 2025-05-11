
enum DrinkType {
  water,
  coffee,
  tea,
  juice,
}

class Drink {
  final DrinkType type;
  final int amount;
  final DateTime timestamp;
  
  Drink({
    required this.type,
    required this.amount,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      type: DrinkType.values[json['type'] as int],
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class Expense {
  String id;
  String jarId;
  double amount;
  String? description;
  DateTime date;

  Expense({
    required this.id,
    required this.jarId,
    required this.amount,
    this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      jarId: json['jarId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'jarId': jarId,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
  };
}

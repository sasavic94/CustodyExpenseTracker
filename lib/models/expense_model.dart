class ExpenseModel {
  int? id;
  int custodyId;
  String title;
  String description;
  double amount;
  String category;
  DateTime date;
  String? receiptImage;
  String? invoiceNumber;

  ExpenseModel({
    this.id,
    required this.custodyId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.receiptImage,
    this.invoiceNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'custodyId': custodyId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'receiptImage': receiptImage,
      'invoiceNumber': invoiceNumber,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      custodyId: map['custodyId'],
      title: map['title'],
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      receiptImage: map['receiptImage'],
      invoiceNumber: map['invoiceNumber'],
    );
  }
}

class CustodyModel {
  int? id;
  String title;
  String description;
  double initialAmount;
  double currentAmount;
  String currency;
  DateTime createdAt;
  List<ExpenseModel> expenses;

  CustodyModel({
    this.id,
    required this.title,
    required this.description,
    required this.initialAmount,
    required this.currentAmount,
    required this.currency,
    required this.createdAt,
    this.expenses = const [],
  });

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);
  double get remainingAmount => initialAmount - totalExpenses;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'initialAmount': initialAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustodyModel.fromMap(Map<String, dynamic> map) {
    return CustodyModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      initialAmount: map['initialAmount'],
      currentAmount: map['currentAmount'],
      currency: map['currency'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

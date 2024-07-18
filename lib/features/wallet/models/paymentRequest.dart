class PaymentRequest {
  PaymentRequest({
    required this.id,
    required this.userId,
    required this.uid,
    required this.paymentType,
    required this.paymentAddress,
    required this.paymentAmount,
    required this.coinUsed,
    required this.details,
    required this.status,
    required this.date,
  });

  PaymentRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String? ?? '';
    userId = json['user_id'] as String? ?? '';
    uid = json['uid'] as String? ?? '';
    paymentType = json['payment_type'] as String? ?? '';
    paymentAddress = json['payment_address'] as String? ?? '';
    paymentAmount = json['payment_amount'] as String? ?? '';
    coinUsed = json['coin_used'] as String? ?? '';
    details = json['details'] as String? ?? '';
    status = json['status'] as String? ?? '';
    date = json['date'] as String? ?? '';
  }

  late final String id;
  late final String userId;
  late final String uid;
  late final String paymentType;
  late final String paymentAddress;
  late final String paymentAmount;
  late final String coinUsed;
  late final String details;
  late final String status;
  late final String date;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['uid'] = uid;
    data['payment_type'] = paymentType;
    data['payment_address'] = paymentAddress;
    data['payment_amount'] = paymentAmount;
    data['coin_used'] = coinUsed;
    data['details'] = details;
    data['status'] = status;
    data['date'] = date;
    return data;
  }
}

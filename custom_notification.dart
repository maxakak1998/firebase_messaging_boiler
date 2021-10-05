import 'dart:convert';

class CustomNotification {
  String? messageBody, model, subject;
  int? resId;

  List<int>? userIds;

  CustomNotification(
      this.messageBody, this.model, this.subject, this.resId, this.userIds);

  CustomNotification.fromJson(Map<String, dynamic> json) {
    messageBody = json['message_body'];
    model = json['model'];
    resId = int.tryParse(json['res_id']);
    subject = json['subject'];
    if (json["user_ids"] != null)
      userIds = jsonDecode(json['user_ids']).cast<int>().toList();

  }


  factory CustomNotification.fromPush(String payload) {
    final decodedJson = jsonDecode(payload);
    return CustomNotification.fromJson(decodedJson);
  }
}

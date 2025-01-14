import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {

  final String serverKey = 'YOUR_SERVER_KEY';

  Future<void> sendNotification({
    required String token, // رمز جهاز المستلم
    required String title, // عنوان الإشعار
    required String body, // محتوى الإشعار
  }) async {
    try {
      // عنوان طلب FCM API
      final String url = 'https://fcm.googleapis.com/fcm/send';

      // محتوى الطلب
      final Map<String, dynamic> notificationData = {
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'priority': 'high',
        'to': token, // إرسال الإشعار إلى رمز جهاز المستلم
      };

      // إرسال الطلب إلى Firebase
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(notificationData),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

# fhttps://github.com/maxakak1998/firebase_messaging_boiler/issuesirebase_messaging_boiler
Boiler code setup for handling notification events

# Related package
 - [firebase_messaging](https://pub.dev/packages/firebase_messaging) (currently is 10.0.8)
 - [rxdart](https://pub.dev/packages/rxdart) (currently is 0.27.2)
 - [flutter_app_badger](https://pub.dev/packages/flutter_app_badger) (currently is 1.3.0)
 
 # 1. Init Firebase Service
  ```dart
     final messagingService=FirebaseMessagingService();
     final remoteMessage = FirebaseMessagingService().await firebaseMessagingService.init();
     
  ```
  You will get the remote message object after completing initialization if the user has clicked on the notification to open an app
 # 2. Listening the notification envents
  ## Notification comming
  ```dart
    firebaseMessagingService.addListener((CustomNotification notification){
      print(notification);
    });
    
  ```
  ## Notification clicking
  ```dart
    firebaseMessagingService.addNotificationClickListener((CustomNotification notification){
      print(notification);
    });
    
  ```
  

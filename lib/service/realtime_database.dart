import 'package:firebase_database/firebase_database.dart';

/// RDBService
class RDBService {
  final _users = FirebaseDatabase.instance.reference().child('users');

  /// getUserData
  Future<dynamic> getUserData() async {
    _users.onChildAdded.listen((event) {
      var _userData = event.snapshot;
      return _userData;
    });
  }

  /// updateLogData
  void upDateLogData(String username) {
    var time = DateTime.now();
    print(time);
    // _users.update(({'timestamp': time}));
    _users.child(username).set({'time': time});
  }
}

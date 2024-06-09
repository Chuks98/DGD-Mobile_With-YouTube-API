// // auth_service.dart
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:daily_grace_devotional/screens/login.dart';
// import 'package:daily_grace_devotional/screens/register.dart';
// import 'notification_widget.dart';

// class AuthService {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   GoogleSignInAccount? _user;

//   Future<GoogleSignInAccount?> signInWithGoogle() async {
//     try {
//       _user = await _googleSignIn.signIn();
//       return _user;
//     } catch (error) {
//       print(error);
//       return null;
//     }
//   }

//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     _user = null;
//   }

//   String? getUserName() {
//     return _user?.displayName;
//   }

//   String? getUserEmail() {
//     return _user?.email;
//   }

//   String? getUserPhotoUrl() {
//     return _user?.photoUrl;
//   }

//   void showGoogleSignInNotification(BuildContext context) {
//     OverlayState? overlayState = Overlay.of(context);

//     if (overlayState == null) {
//       print('No overlay found in the provided context');
//       return; 
//     }

//     late OverlayEntry overlayEntry;
//     overlayEntry = OverlayEntry(
//       builder: (context) => NotificationWidget(
//         email: 'example@gmail.com', // This should be dynamic
//         onSignIn: () async {
//           GoogleSignInAccount? user = await signInWithGoogle();
//           if (user != null) {
//             overlayEntry.remove(); // Close the notification
//             // Navigate to home or any other page
//           }
//         },
//         onRegister: () {
//           overlayEntry.remove(); // Close the notification
//           Navigator.of(context)
//               .push(MaterialPageRoute(builder: (context) => Register()));
//         },
//         onLogin: () {
//           overlayEntry.remove(); // Close the notification
//           Navigator.of(context)
//               .push(MaterialPageRoute(builder: (context) => Login()));
//         },
//         onCancel: () {
//           overlayEntry.remove(); // Close the notification
//         },
//       ),
//     );

//     overlayState.insert(overlayEntry);
//   }
// }

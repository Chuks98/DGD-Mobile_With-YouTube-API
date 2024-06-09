// // notification_widget.dart
// import 'package:flutter/material.dart';

// class NotificationWidget extends StatefulWidget {
//   final String email;
//   final VoidCallback onSignIn;
//   final VoidCallback onRegister;
//   final VoidCallback onLogin;
//   final VoidCallback onCancel;

//   NotificationWidget({
//     required this.email,
//     required this.onSignIn,
//     required this.onRegister,
//     required this.onLogin,
//     required this.onCancel,
//   });

//   @override
//   _NotificationWidgetState createState() => _NotificationWidgetState();
// }

// class _NotificationWidgetState extends State<NotificationWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _offsetAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _offsetAnimation = Tween<Offset>(
//       begin: const Offset(1, 0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _offsetAnimation,
//       child: Container(
//         padding: EdgeInsets.all(10),
//         margin: EdgeInsets.only(top: 50, right: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             ElevatedButton.icon(
//               icon: Image.asset(
//                 'assets/google_icon.png',
//                 height: 20.0,
//                 width: 20.0,
//               ),
//               label: Text('Continue as ${widget.email}'),
//               onPressed: widget.onSignIn,
//             ),
//             Divider(),
//             Text('or manually'),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: widget.onRegister,
//                   child: Text('Register'),
//                 ),
//                 ElevatedButton(
//                   onPressed: widget.onLogin,
//                   child: Text('Login'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: widget.onCancel,
//               child: Text('Cancel'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (error) {
      print("Error during silent sign-in: $error");
      return null;
    }
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Attempt to sign in the user
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // If the user cancels the sign-in process
        return null;
      }

      // Retrieve user profile information
      final String? username = googleUser.displayName;
      final String? email = googleUser.email;
      final String? profilePicture = googleUser.photoUrl;

      return {
        'username': username,
        'email': email,
        'profilePicture': profilePicture,
      };
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }

  Future<bool> isGoogleAccountAvailable() async {
    try {
      // Check if a Google account is available on the device
      final bool hasAccounts = await _googleSignIn.isSignedIn();
      return hasAccounts;
    } catch (error) {
      print("Error checking Google accounts: $error");
      return false;
    }
  }
}

import 'package:chat_app/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  User? get currentUser => _supabase.auth.currentUser;

  bool get isLoggedIn => _supabase.auth.currentUser != null;

  Future<UserModel> signup({
    required String email,
    required String password,
    required String userName,
    String? fullName,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': userName, 'full_name': fullName ?? ''},
      );
      if (response.user == null) {
        throw Exception('Signup failed');
      }
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();
      return UserModel.fromJson(profileData);
    } on AuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Sign in failed');
      }
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();
      return UserModel.fromJson(profileData);
    } on AuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
  Future<UserModel> getCurrentUserProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('No user is currently signed in');
      }
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }
  Future<UserModel> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('No authenticated user');
      }
      final updates = {
        if(username != null) 'username': username,
        if(fullName != null) 'full_name': fullName,
        if(avatarUrl != null) 'avatar_url': avatarUrl,
        if(bio != null) 'bio': bio,
        'updated_at': DateTime.now().toIso8601String(),
      };
      final profileData = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Failed to send password reset email: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}

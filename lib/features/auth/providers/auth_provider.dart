import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/graphql/client.dart';
import '../../../core/graphql/mutations.dart';

const _storage = FlutterSecureStorage();
const _tokenKey = 'shopify_customer_token';
const _firstNameKey = 'customer_first_name';
const _lastNameKey = 'customer_last_name';
const _emailKey = 'customer_email';

class AuthState {
  final bool isLoggedIn;
  final String? accessToken;
  final String? customerFirstName;
  final String? customerLastName;
  final String? customerEmail;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.accessToken,
    this.customerFirstName,
    this.customerLastName,
    this.customerEmail,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? accessToken,
    String? customerFirstName,
    String? customerLastName,
    String? customerEmail,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        accessToken: accessToken ?? this.accessToken,
        customerFirstName: customerFirstName ?? this.customerFirstName,
        customerLastName: customerLastName ?? this.customerLastName,
        customerEmail: customerEmail ?? this.customerEmail,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return;
    final firstName = await _storage.read(key: _firstNameKey);
    final lastName = await _storage.read(key: _lastNameKey);
    final email = await _storage.read(key: _emailKey);
    state = state.copyWith(
      isLoggedIn: true,
      accessToken: token,
      customerFirstName: firstName,
      customerLastName: lastName,
      customerEmail: email,
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ShopifyGraphQLClient.mutate(
        MutationOptions(
          document: gql(ShopifyMutations.customerAccessTokenCreateMutation),
          variables: {
            'input': {'email': email, 'password': password},
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final data = result.data?['customerAccessTokenCreate'];
      final errors = data?['customerUserErrors'] as List<dynamic>? ?? [];
      if (errors.isNotEmpty) {
        final msg = (errors[0] as Map<String, dynamic>)['message'] as String;
        state = state.copyWith(isLoading: false, error: msg);
        return false;
      }

      final tokenData = data?['customerAccessToken'] as Map<String, dynamic>?;
      final accessToken = tokenData?['accessToken'] as String?;
      if (accessToken == null) {
        state = state.copyWith(
            isLoading: false, error: 'Invalid credentials');
        return false;
      }

      await _storage.write(key: _tokenKey, value: accessToken);
      await _storage.write(key: _emailKey, value: email);

      state = state.copyWith(
        isLoggedIn: true,
        accessToken: accessToken,
        customerEmail: email,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ShopifyGraphQLClient.mutate(
        MutationOptions(
          document: gql(ShopifyMutations.customerCreateMutation),
          variables: {
            'input': {
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
              'password': password,
            },
          },
        ),
      );

      if (result.hasException) throw Exception(result.exception.toString());

      final data = result.data?['customerCreate'];
      final errors = data?['customerUserErrors'] as List<dynamic>? ?? [];
      if (errors.isNotEmpty) {
        final msg = (errors[0] as Map<String, dynamic>)['message'] as String;
        state = state.copyWith(isLoading: false, error: msg);
        return false;
      }

      // Auto-login after registration
      return await login(email: email, password: password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final token = state.accessToken;
    if (token != null) {
      await ShopifyGraphQLClient.mutate(
        MutationOptions(
          document: gql(ShopifyMutations.customerAccessTokenDeleteMutation),
          variables: {'customerAccessToken': token},
        ),
      );
    }
    await _storage.deleteAll();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

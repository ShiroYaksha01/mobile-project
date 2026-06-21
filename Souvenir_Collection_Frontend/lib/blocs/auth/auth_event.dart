abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested(this.email, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class AuthLogoutRequested extends AuthEvent {}

class UserModel {
  final String id;
  final String email;
  final String nombre;

  UserModel({
    required this.id,
    required this.email,
    required this.nombre,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
    };
  }
}
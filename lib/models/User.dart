/**
 * les models sont immutable(final) pour eviter:
 * -les modifications
 * -faciliter la gestion d'etat
 */

class User {
  //identifiant unique de l'utilisateur(UUID)
  final String id;

  // Nom complet de l'utilisateur
  final String name;

  final String email;

  final String password;

  final String? avatar;

  final DateTime createdAt;


  //constructeur
User({
     required this.id,
     required this.name,
     required this.email,
     required this.password,
     this.avatar,
     DateTime? createdAt,
}) : createdAt = createdAt ?? DateTime.now();

  /**
   * ca permet de creer une copie de l'utilisateur avec des chemps modifies
   * Ex: final updateUser = user.
   */
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? avatar,
    DateTime? createdAt,


}){
  return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt
  );
}

  /**
   * ca permet de convertir l'utilisateur en Map  c'est ca qu'on appelle la
   * serialisation:
   * -c'est util pour sauvgarder dans shared_preferances ou envoyer a une API
   */
  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'name': name,
      'emil': email,
      'password': password,
      'avatar': avatar,
      'createdAt':createdAt
    };
}

  /**
   * ca permet de creer un objet c'est comme un constructeur
   * creer un utilisateur a l'aide du constructeur factory depuis un Map
   */
  factory User.fromMap(Map<String, dynamic> map){
  return User(
      id: map['id'] as String,
      name:map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      avatar: map['avatar'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String)

  );

}

@override
  String toString() {
    return 'User(id: $id, name: $name, emil: $email)';
  }
}
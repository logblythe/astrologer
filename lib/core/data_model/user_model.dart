class UserModel {
  int userId;
  String firstName;
  String lastName;
  String password;
  String email;
  String phoneNumber;
  String gender;
  String city;
  String state;
  String country;
  String role;
  String dateOfBirth;
  String birthTime;
  bool accurateTime;
  String errorMessage;

  UserModel({
    this.userId,
    this.firstName,
    this.lastName,
    this.password,
    this.email,
    this.phoneNumber,
    this.gender,
    this.city,
    this.state,
    this.country,
    this.role,
    this.dateOfBirth,
    this.birthTime,
    this.accurateTime,
  });

  UserModel.error({String error}) {
    errorMessage = error;
  }

  UserModel.fromError(Map<String, dynamic> json)
      : errorMessage = json['message'];

  UserModel.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        password = json['password'],
        email = json['email'],
        phoneNumber = json['phoneNumber'],
        gender = json['gender'],
        city = json['city'],
        state = json['state'],
        country = json['country'],
        role = json['role'],
        dateOfBirth = json['dateOfBirth'],
        birthTime = json['birthTime'],
        accurateTime = json['accurateTime'] ?? false,
        errorMessage = json['message'];

  UserModel.fromDb(Map<String, dynamic> json)
      : userId = json['userId'] as int,
        firstName = json['firstName'],
        lastName = json['lastName'],
        email = json['email'],
        password = json['password'],
        phoneNumber = json['phoneNumber'],
        gender = json['gender'],
        city = json['city'],
        state = json['state'],
        country = json['country'],
        role = json['role'],
        dateOfBirth = json['dateOfBirth'],
        birthTime = json['birthTime'],
        accurateTime = json['accurateTime'] == 1;

  Map<String, dynamic> toMapForDb() => {
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phoneNumber": phoneNumber,
        "password": password,
        "gender": gender,
        "city": city,
        "state": state,
        "country": country,
        "role": role,
        "dateOfBirth": dateOfBirth,
        "birthTime": birthTime,
        "accurateTime": accurateTime,
      };

  @override
  String toString() {
    return toMapForDb().toString();
  }
}

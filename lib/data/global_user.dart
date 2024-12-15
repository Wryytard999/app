class GlobalUser {
  static int? id;
  static String? username;
  static String? password;
  static String? email;
  static String? role;
  static String? verificationToken;
  static bool? validate;

  static void setUserData(Map<String, dynamic> data) {
    id = data['id'];
    username = data['username'];
    password = data['password'];
    email = data['email'];
    role = data['role'];
    verificationToken = data['verificationToken'];
    validate = data['validate'];
  }

  static void clearUserData() {
    id = null;
    username = null;
    password = null;
    email = null;
    role = null;
    verificationToken = null;
    validate = null;
  }

  static bool isProf() {
    if (role == "PROFESSEUR") {
      return true;
    }
    return false;
  }

  static bool isCoor() {
    if (role == "COORDINATEUR") {
      return true;
    }
    return false;
  }

  static bool isRespo() {
    if (role == "RESPONSABLE_SALLES") {
      return true;
    }
    return false;
  }
}

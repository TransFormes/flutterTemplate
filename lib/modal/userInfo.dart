class AcountBasicModal {
  String email;
  String name;
  bool haspwd;

  AcountBasicModal({this.email, this.name, this.haspwd});

  AcountBasicModal.fromJson(Map<String, dynamic> json) {
    email = json['email'] ?? '';
    name = json['name'] ?? '';
    haspwd = json['haspwd'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['name'] = this.name;
    data['haspwd'] = this.haspwd;
    return data;
  }
}

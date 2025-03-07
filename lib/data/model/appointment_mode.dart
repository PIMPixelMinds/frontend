class Appointment {
  final String fullName;
  final DateTime date;
  final String phone;
  final String status;
  final String fcmToken;

  Appointment(
      {required this.fullName,
      required this.date,
      required this.phone,
      required this.status,
      required this.fcmToken});

  // Convert JSON to Appointment object
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      fullName: json['fullName'] ?? "",
      date:json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      phone: json['phone'] ?? "",
      status: json['status'] ?? "Upcoming",
      fcmToken: json['fcmToken'] ?? ""
    );
  }

  // Convert Appointment object to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'date': date.toIso8601String(),
      'phone': phone,
      'status': status,
      'fcmToken': fcmToken
    };
  }
}

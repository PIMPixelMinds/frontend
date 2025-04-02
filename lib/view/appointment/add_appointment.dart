import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pim/data/model/appointment_mode.dart';
import 'package:pim/view/appointment/firebase_api.dart';
import 'package:pim/viewmodel/appointment_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  _AddAppointmentPageState createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  DateTime? selectedDate;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _fetchFcmToken();
  }

  Future<void> _fetchFcmToken() async {
    final token = await FirebaseApi().getFcmToken();
    setState(() {
      fcmToken = token;
    });
    print("Fetched FCM Token: $fcmToken");
  }

  @override
  Widget build(BuildContext context) {
    final appointmentViewModel = Provider.of<AppointmentViewModel>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Full Name", "Enter Doctor Name",
                        fullNameController, false, isDarkMode),
                    const SizedBox(height: 20),
                    _buildDatePickerField(isDarkMode),
                    const SizedBox(height: 20),
                    _buildPhoneField(isDarkMode),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(appointmentViewModel, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: selectedDate != null
                ? DateFormat.yMMMd().format(selectedDate!)
                : "Select Appointment Date",
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(bool isDarkMode) {
    return IntlPhoneField(
      controller: phoneController,
      decoration: InputDecoration(
        labelText: 'Enter Doctor Phone Number',
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        border: OutlineInputBorder(),
      ),
      initialCountryCode: 'TN',
      onChanged: (phone) {},
    );
  }

  Widget _buildBottomButton(AppointmentViewModel viewModel, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: ElevatedButton(
        onPressed: () async {
          if (fullNameController.text.isEmpty ||
              selectedDate == null ||
              phoneController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please fill all fields")),
            );
            return;
          }

          final appointment = Appointment(
              fullName: fullNameController.text.trim(),
              date: selectedDate!,
              phone: phoneController.text,
              status: "Upcoming",
              fcmToken: fcmToken ?? "");

          print(appointment.toJson());
          final jsonData = jsonEncode(appointment.toJson());
          print(jsonData);
          await viewModel.addAppointment(appointment);

          if (viewModel.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(viewModel.errorMessage!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Appointment added successfully!")),
            );

            await viewModel.fetchAppointments();
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: viewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Add Appointment",
                style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 150),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/appointmentAdd.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      TextEditingController controller, bool isPassword, bool isDarkMode) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pim/core/constants/app_colors.dart';
import 'package:pim/data/model/appointment_mode.dart';
import 'package:pim/viewmodel/appointment_viewmodel.dart';
import 'package:provider/provider.dart';

enum FilterStatus { Upcoming, Completed, Canceled }

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status = FilterStatus.Upcoming;
  Alignment _alignment = Alignment.centerLeft;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentViewModel>(context, listen: false)
          .fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Appointment Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _weekDaysView(isDarkMode),
            const SizedBox(height: 20),
            _datePickerView(isDarkMode),
            const SizedBox(height: 20),
            _filterTabs(isDarkMode),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<AppointmentViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Filter appointments based on selected status
                  List<Appointment> filteredAppointments = viewModel
                      .appointments
                      .where((appointment) => appointment.status == status.name)
                      .toList();

                  return filteredAppointments.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 0),
                              child: ListTile(
                                leading: Icon(Icons.event,
                                    color: AppColors.primaryBlue),
                                title: Text(appointment.fullName),
                                subtitle: Text(
                                  DateFormat.yMMMd().format(appointment.date),
                                ),
                                trailing: IconButton(
                                    icon: Icon(Icons.cancel,
                                        color: AppColors.error),
                                    onPressed: () async {
                                      viewModel.cancelAppointment(
                                          appointment.fullName);
                                      viewModel.fetchAppointments();
                                    }),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "No ${status.name} appointments",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekDaysView(bool isDarkMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMd().format(DateTime.now()),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? const Color.fromARGB(165, 226, 226, 226)
                          : Colors.grey),
                ),
                Text(
                  "Today",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              ],
            ),
            _addAppointmentButton(
                () => Navigator.pushNamed(context, '/addAppointment'),
                "Add Appointment"),
          ],
        ),
      ],
    );
  }

  Widget _datePickerView(bool isDarkMode) {
    return Container(
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: AppColors.primaryBlue,
        selectedTextColor: Colors.white,
        dateTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey : Colors.black),
        monthTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey : Colors.black),
        dayTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey : Colors.black),
        controller: DatePickerController(),
      ),
    );
  }

  Widget _filterTabs(bool isDarkMode) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white
                : const Color.fromARGB(218, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (FilterStatus filterStatus in FilterStatus.values)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        status = filterStatus;
                        if (status == FilterStatus.Upcoming) {
                          _alignment = Alignment.centerLeft;
                        } else if (status == FilterStatus.Completed) {
                          _alignment = Alignment.center;
                        } else if (status == FilterStatus.Canceled) {
                          _alignment = Alignment.centerRight;
                        }
                      });
                    },
                    child: Center(
                      child: Text(
                        filterStatus.name,
                        style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode ? Colors.black : Colors.black),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        AnimatedAlign(
          alignment: _alignment,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 120,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                status.name,
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addAppointmentButton(Function()? onTap, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.primaryBlue,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/add.png', height: 15, width: 15),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

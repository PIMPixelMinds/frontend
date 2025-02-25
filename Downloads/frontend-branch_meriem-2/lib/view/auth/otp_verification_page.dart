import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Import pour filtrer les entrées numériques
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodel/auth_viewmodel.dart';
import 'reset_password_bottom_sheet.dart';

class OTPVerificationBottomSheet extends StatefulWidget {
  final String email;

  const OTPVerificationBottomSheet({
    super.key,
    required this.email,
  });

  @override
  _OTPVerificationBottomSheetState createState() =>
      _OTPVerificationBottomSheetState();
}

class _OTPVerificationBottomSheetState
    extends State<OTPVerificationBottomSheet> {
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  int _timeRemaining = 90;
  late Timer _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        setState(() {
          _canResend = true;
          _timer.cancel();
        });
      }
    });
  }

  String get formattedTime {
    int minutes = _timeRemaining ~/ 60;
    int seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onOTPEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
  }

  void _showResetPasswordBottomSheet(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ResetPasswordBottomSheet(email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),

          // ✅ Titre amélioré
          Text(
            "Vérification du Code",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // ✅ Texte d'instruction
          Text(
            "Veuillez entrer le code envoyé à\n${widget.email}",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 20),

          // ✅ Champs OTP améliorés
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              6,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  width: 50,
                  height: 55,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (value) => _onOTPEntered(index, value),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // ✅ Permet seulement les chiffres
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100], // ✅ Adaptation mode sombre/clair
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Compteur avec des couleurs adaptées
          Text(
            formattedTime,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 10),

          // ✅ Bouton "Renvoyer"
          TextButton(
            onPressed: _canResend ? () => authViewModel.resendOtp(context, widget.email) : null,
            child: Text(
              "Vous n’avez pas reçu de code ? Renvoyer",
              style: TextStyle(
                color: _canResend ? AppColors.primaryBlue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Bouton "Vérifier" modernisé
          authViewModel.isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      String otpCode = otpControllers.map((c) => c.text.trim()).join();
                      if (otpCode.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Veuillez entrer un code OTP valide de 6 chiffres.")),
                        );
                        return;
                      }

                      bool isVerified = await authViewModel.verifyOtp(context, widget.email, otpCode);
                      if (isVerified) {
                        _showResetPasswordBottomSheet(context, widget.email);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      "Vérifier",
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

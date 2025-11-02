import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DeleteAccountPage extends NyStatefulWidget {
  static RouteView path = ("/delete-account", (_) => DeleteAccountPage());

  DeleteAccountPage({super.key})
      : super(child: () => _DeleteAccountPageState());
}

class _DeleteAccountPageState extends NyPage<DeleteAccountPage> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[800],
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _buildLogoSection(),

              const SizedBox(height: 40),

              _buildTagline(),

              const SizedBox(height: 40),

              _buildConfirmationMessage(),

              const Spacer(),

              _buildActionButtons(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [

        Image.asset(
          'logo.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ).localAsset(),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'insp',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4), // Bright pink
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'i',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700), // Yellow
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'rtag',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BFFF), // Blue
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Text(
      'Where Self Expression Meets\nInspiration and Recognition',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildConfirmationMessage() {
    return Text(
      "Are you sure you want to delete your account?\nYou can't undo it",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[700],
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              showToastSuccess(
                  title: "Delete Account",
                  description: "Account deletion confirmed");

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00BFFF), // Bright blue
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFF00BFFF), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:samvaad/screens/session_feedback_screen.dart';
import 'package:samvaad/utils/app_colors.dart';

class TherapistBookingScreen extends StatefulWidget {
  static const String routeName = '/therapist-booking';
  const TherapistBookingScreen({super.key});

  @override
  State<TherapistBookingScreen> createState() => _TherapistBookingScreenState();
}

class _TherapistBookingScreenState extends State<TherapistBookingScreen> {
  int _step = 0; // 0: Select Slot, 1: Payment Summary
  int _selectedDateIndex = 1; // Wednesday
  int _selectedTimeIndex = 0; // 09:00 AM

  // Mock data for date and time selection
  final List<Map<String, dynamic>> dates = [
    {'day': 'Mon', 'date': 15},
    {'day': 'Tue', 'date': 16},
    {'day': 'Wed', 'date': 17},
    {'day': 'Thu', 'date': 18},
    {'day': 'Fri', 'date': 19},
  ];

  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    // Get therapist data from arguments
    final Map<String, dynamic> therapist =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {'name': 'Dr. Sarah Johnson', 'specialty': 'Anxiety & Stress', 'fee': 80};

    String appBarTitle = _step == 0 ? 'Select Time Slot' : 'Payment';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (_step == 0) {
              Navigator.of(context).pop();
            } else {
              setState(() => _step = 0);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Therapist Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Avatar Placeholder
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.accent.withOpacity(0.5),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(therapist['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(therapist['specialty'], style: const TextStyle(color: AppColors.greyText)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            _step == 0
                ? _buildTimeSlotSelector(therapist)
                : _buildPaymentSummary(therapist),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelector(Map<String, dynamic> therapist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        // Date Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dates.length, (index) {
            bool isSelected = _selectedDateIndex == index;
            return _DatePill(
              day: dates[index]['day'],
              date: dates[index]['date'],
              isSelected: isSelected,
              onTap: () => setState(() => _selectedDateIndex = index),
            );
          }),
        ),
        const SizedBox(height: 30.0),

        const Text('Available Slots',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),
        // Time Slot Selector
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: List.generate(timeSlots.length, (index) {
            bool isSelected = _selectedTimeIndex == index;
            return _TimePill(
              time: timeSlots[index],
              isSelected: isSelected,
              onTap: () => setState(() => _selectedTimeIndex = index),
            );
          }),
        ),
        const SizedBox(height: 40.0),

        // Continue Button
        ElevatedButton(
          onPressed: () => setState(() => _step = 1),
          child: const Text('Continue to Payment'),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(Map<String, dynamic> therapist) {
    String selectedDate =
        '${dates[_selectedDateIndex]['day']}, Oct ${dates[_selectedDateIndex]['date']}th';
    String selectedTime = timeSlots[_selectedTimeIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),

        _buildSummaryRow('Therapist', therapist['name']),
        _buildSummaryRow('Date & Time', '$selectedDate at $selectedTime'),
        _buildSummaryRow('Session Type', 'Video Call (50 min)'),
        _buildSummaryRow('Total Amount', '\$${therapist['fee'].toStringAsFixed(2)}', isTotal: true),

        const SizedBox(height: 30.0),
        const Text('Payment Method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16.0),

        // Card Details (Mockups)
        const Text('Card Number', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        const TextField(
          decoration: InputDecoration(hintText: '1234 5678 9012 3456'),
        ),
        const SizedBox(height: 16.0),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Expiry', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8.0),
                  const TextField(
                    decoration: InputDecoration(hintText: 'MM/YY'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CVV', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8.0),
                  const TextField(
                    decoration: InputDecoration(hintText: '123'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40.0),

        // Confirm and Pay Button
        ElevatedButton(
          onPressed: () {
            // In a real app, this would process payment and navigate to the chat/session screen
            // For now, navigate to the Session Feedback screen after a mock session
            Navigator.of(context).pushReplacementNamed(
                '/chat-session-placeholder'); // Placeholder to show it's a new screen
          },
          child: Text('Confirm & Pay \$${therapist['fee'].toStringAsFixed(2)}'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.greyText)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String day;
  final int date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DatePill({
    required this.day,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              date.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimePill({
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.3) : AppColors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? AppColors.darkText : AppColors.darkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Placeholder for the actual session/chat screen before feedback
class PlaceholderChatSessionScreen extends StatelessWidget {
  static const String routeName = '/chat-session-placeholder';
  const PlaceholderChatSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dr. Sarah Johnson')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Session in Progress...', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate ending the session and going to feedback
                Navigator.of(context).pushReplacementNamed(SessionFeedbackScreen.routeName);
              },
              child: const Text('End Session'),
            ),
          ],
        ),
      ),
    );
  }
}

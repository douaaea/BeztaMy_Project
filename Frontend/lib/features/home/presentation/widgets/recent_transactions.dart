import 'package:flutter/material.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  // Asset paths used by this widget (these files are present in `assets/images`).
  static const String arrowUp1 = 'assets/images/arrow_up_1.png';
  static const String arrowUp2 = 'assets/images/arrow_up_2.png';
  static const String arrowDown1 = 'assets/images/arrow_down_1.png';
  static const String arrowDown2 = 'assets/images/arrow_down_2.png';


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDEE1E6)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
              color: Color(0xFF171A1F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your latest income and expense activities.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.normal,
              fontSize: 14.0,
              color: Color(0xFF565D6D),
            ),
          ),
          const SizedBox(height: 22),
          _buildTransactionItem(
            icons: [arrowUp1, arrowUp2],
            title: 'Salary Deposit',
            date: '2024-06-25',
            amount: '+ \$3,500.00',
            amountColor: Colors.green,
          ),
          const SizedBox(height: 26),
          _buildTransactionItem(
            icons: [arrowDown1, arrowDown2],
            title: 'Grocery Shopping',
            date: '2024-06-24',
            amount: '- \$120.50',
            amountColor: Colors.red,
          ),
          const SizedBox(height: 26),
          _buildTransactionItem(
            icons: [arrowUp1, arrowUp2],
            title: 'Freelance Payment',
            date: '2024-06-22',
            amount: '+ \$800.00',
            amountColor: Colors.green,
          ),
          const SizedBox(height: 26),
          _buildTransactionItem(
            icons: [arrowDown1, arrowDown2],
            title: 'Internet Bill',
            date: '2024-06-20',
            amount: '- \$65.00',
            amountColor: Colors.red,
          ),
          const SizedBox(height: 26),
          _buildTransactionItem(
            icons: [arrowDown1, arrowDown2],
            title: 'Dinner Out',
            date: '2024-06-19',
            amount: '- \$75.30',
            amountColor: Colors.red,
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDEE1E6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: const Text(
                'View All Transactions',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                  color: Color(0xFF171A1F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required List<String> icons,
    required String title,
    required String date,
    required String amount,
    required Color amountColor,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Stack(
            children: icons.map((icon) => Image.asset(icon, fit: BoxFit.contain)).toList(),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
                color: Color(0xFF171A1F),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              date,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.normal,
                fontSize: 14.0,
                color: Color(0xFF565D6D),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

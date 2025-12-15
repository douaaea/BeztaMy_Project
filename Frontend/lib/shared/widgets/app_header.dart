import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        children: [
          const SizedBox(height: 7),
          Row(
            children: [
              // Logo
              Container(
                width: 171,
                height: 66,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/beztami_logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7E2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD7CA42)),
                ),
                child: Stack(
                  children: [
                    // Avatar image placeholder
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF20DF60),
                          borderRadius: BorderRadius.circular(4.5),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const Divider(height: 1, color: Color(0xFFDEE1E6)),
        ],
      ),
    );
  }
}

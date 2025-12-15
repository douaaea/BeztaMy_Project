import 'package:flutter/material.dart';

class UserAvatarMenu extends StatelessWidget {
  final double size;
  final String name;
  final String email;
  final ImageProvider? image;

  const UserAvatarMenu({
    super.key,
    this.size = 40,
    this.name = 'BeztaMy User',
    this.email = 'user@beztamy.com',
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFF4CAF50),
      backgroundImage: image,
      child: image == null ? const Icon(Icons.person, color: Colors.white) : null,
    );

    return PopupMenuButton<int>(
      tooltip: 'Account',
      offset: Offset(0, size / 2 + 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF1B5E20),
                  backgroundImage: image,
                  child: image == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1B4332),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6F6F6F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      child: avatar,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/components/tw_profile_avatar.dart';

class PassengerGroupChatScreen extends StatefulWidget {
  const PassengerGroupChatScreen({super.key});

  @override
  State<PassengerGroupChatScreen> createState() => _PassengerGroupChatScreenState();
}

class _PassengerGroupChatScreenState extends State<PassengerGroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Amara (Creator)',
      'initials': 'AM',
      'message': 'Hey guys! I\'m already at the Yaba bus stop by the bakery.',
      'time': '08:05 AM',
      'isMe': false,
    },
    {
      'sender': 'Chike',
      'initials': 'CH',
      'message': 'Coming, just got off the bike. 2 mins away.',
      'time': '08:07 AM',
      'isMe': false,
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'sender': 'You',
        'initials': 'ME',
        'message': _messageController.text.trim(),
        'time': 'Now',
        'isMe': true,
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yaba → Lekki Commuters',
              style: GoogleFonts.outfit(
                color: AppColors.paper,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '3 people online',
              style: GoogleFonts.manrope(
                color: AppColors.kekeGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Area
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['isMe'] as bool;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) ...[
                          TWProfileAvatar(initials: msg['initials'], radius: 14.0),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                                  child: Text(
                                    msg['sender'],
                                    style: GoogleFonts.manrope(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.kekeGreen : AppColors.cardBackground,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 16),
                                  ),
                                ),
                                child: Text(
                                  msg['message'],
                                  style: GoogleFonts.manrope(
                                    color: isMe ? AppColors.ink : AppColors.paper,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0, right: 4.0),
                                child: Text(
                                  msg['time'],
                                  style: GoogleFonts.manrope(
                                    color: AppColors.muted.withOpacity(0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isMe) const SizedBox(width: 24), // spacing for 'me' alignment
                      ],
                    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0),
                  );
                },
              ),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(top: BorderSide(color: AppColors.borderStroke)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderStroke),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.manrope(color: AppColors.paper),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.manrope(color: AppColors.muted),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.kekeGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

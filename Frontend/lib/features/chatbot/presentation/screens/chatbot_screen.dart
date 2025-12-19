import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:audioplayers/audioplayers.dart'; // For PlayerState

import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/user_avatar_menu.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../domain/providers/chatbot_provider.dart';
import '../../domain/providers/audio_providers.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {
      'from': 'bot',
      'text': 'Hello! How can I help you with your BeztaMy finances today?',
    },
  ];

  // Audio State
  bool _isListening = false;
  bool _isLoading = false;
  String? _playingText;

  // Session
  String _sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';

  // TtsService is updated via ref.read in initState

  late final _sttService;

  @override
  void initState() {
    super.initState();
    
    _sttService = ref.read(sttServiceProvider);

    // Initialize STT (following documentation pattern)
    // Works on mobile, limited browser support on web
    _initSpeech();

    // Listen to player state to reset playing icon
    final ttsService = ref.read(ttsServiceProvider);
    ttsService.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        if (mounted) {
          setState(() {
            _playingText = null;
          });
        }
      }
    });
  }

  /// Initialize speech recognition once per screen load
  /// This follows the official speech_to_text documentation pattern
  void _initSpeech() async {
    await _sttService.init();
    if (mounted) {
      setState(() {
        // Trigger rebuild to update UI based on STT availability
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    // Clean up STT service if it's listening
    // use stored reference instead of ref.read
    _sttService.dispose();

    // TTS service is disposed by Riverpod provider
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final showSidebar = !isMobile;
    final showInlineHeader = !isMobile;
    return Scaffold(
      key: _scaffoldKey,
      appBar: isMobile ? _buildAppBar() : null,
      drawer: isMobile ? _buildDrawer() : null,
      backgroundColor: AppConstants.appBackgroundColor,
      body: Row(
        children: [
          if (showSidebar) const AppSidebar(activeItem: 'Chatbot'),
          Expanded(
            child: Column(
              children: [
                if (showInlineHeader) ...[
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/beztami_logo.png',
                          height: 48,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chat with BeztaMy Assistant',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'AI insights tailored to your finances',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6F6F6F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  const SizedBox(height: 12),
                if (!isMobile) ...[
                  const SizedBox(height: 12),
                  _buildHighlightCard(),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 980),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(color: const Color(0xFFE3E5EB)),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 500,
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(24),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final msg = _messages[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 18.0,
                                    ),
                                    child: msg['from'] == 'bot'
                                        ? _buildBotMessage(msg['text']!)
                                        : _buildUserMessage(msg['text']!),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildQuickAction(
                                    Icons.auto_graph,
                                    'Summarize my spending',
                                  ),
                                  _buildQuickAction(
                                    Icons.restaurant,
                                    'How much on food last month?',
                                  ),
                                  _buildQuickAction(
                                    Icons.warning_amber,
                                    'Largest expenses',
                                  ),
                                  _buildQuickAction(
                                    Icons.receipt_long,
                                    'Where is my income report?',
                                  ),
                                  _buildQuickAction(
                                    Icons.savings,
                                    'Help me set a budget',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFDEE1E6)),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAFAFB),
                                        border: Border.all(
                                          color: const Color(0xFFBDC1CA),
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Center(
                                        child: TextField(
                                          controller: _controller,
                                          onSubmitted: (_) => _sendMessage(),
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Type your message here...',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 14,
                                              color: Color(0xFF565D6D),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF43A047),
                                          Color(0xFF2E7D32),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        // Mic button (works on mobile, limited on web)
                                        IconButton(
                                          icon: Icon(
                                            _isListening
                                                ? Icons.mic
                                                : Icons.mic_none,
                                            color: _isListening
                                                ? Colors.red
                                                : Colors.white,
                                            size: 20,
                                          ),
                                          tooltip: _isListening
                                              ? 'Stop listening'
                                              : 'Speak',
                                          onPressed: _toggleListening,
                                        ),
                                        IconButton(
                                          icon: _isLoading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : const Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                          onPressed: _isLoading
                                              ? null
                                              : _sendMessage,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isListening)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.fiber_manual_record,
                                      color: Color(0xFFE53935),
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Listening...',
                                      style: TextStyle(
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    '© 2025 BeztaMy. All rights reserved.',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Color(0xFF565D6D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.black87),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black87),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Image.asset('assets/images/beztami_logo.png', height: 36),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Chat with BeztaMy Assistant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF171A1F),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: UserAvatarMenu(size: 36),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return const Drawer(child: AppSidebar(activeItem: 'Chatbot'));
  }

  Widget _buildBotMessage(String text) {
    final isPlaying = _playingText == text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9D7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFB3B81E)),
          ),
          child: Stack(
            children: [
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
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _playText(text),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
              size: 20,
              color: isPlaying ? Colors.red : const Color(0xFF565D6D),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                color: Color(0xFF171A1F),
              ),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF4FA759),
                borderRadius: BorderRadius.circular(16),
              ),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  color: Colors.white,
                ),
                softWrap: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return InkWell(
      onTap: () {
        _controller.text = label;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1B4332)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xFF1B4332),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need inspiration?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ask about budgeting tips, unusual spending spikes, or saving streaks.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                _controller.text = 'Give me smart savings ideas';
                _sendMessage();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message to chat
    setState(() {
      _messages.add({'from': 'user', 'text': text});
      _controller.clear();
      _isLoading = true;
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      // Get chatbot service and user ID
      final chatbotService = ref.read(chatbotServiceProvider);
      final userId = ref.read(userIdProvider);

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Send message to backend
      final response = await chatbotService.sendMessage(
        question: text,
        sessionId: _sessionId,
        userId: userId,
      );

      // Add bot response to chat
      if (mounted) {
        setState(() {
          _messages.add({'from': 'bot', 'text': response});
          _isLoading = false;
        });

        // Scroll to bottom after response
        Future.delayed(const Duration(milliseconds: 150), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 200,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        setState(() {
          _messages.add({
            'from': 'bot',
            'text':
                'Sorry, I encountered an error: ${e.toString()}. Please try again.',
          });
          _isLoading = false;
        });

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playText(String text) async {
    final ttsService = ref.read(ttsServiceProvider);

    if (_playingText == text) {
      await ttsService.stop();
      setState(() {
        _playingText = null;
      });
      return;
    }

    try {
      setState(() {
        _playingText = text;
      });
      await ttsService.play(text);
    } catch (e) {
      if (mounted) {
        setState(() {
          _playingText = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Audio play failed: $e')));
      }
    }
  }

  Future<void> _toggleListening() async {
    final sttService = ref.read(sttServiceProvider);

    // Check if speech recognition is available (following doc pattern)
    if (!sttService.isEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_isListening) {
      await sttService.stopListening();
      setState(() {
        _isListening = false;
      });
      return;
    }

    try {
      await sttService.startListening((text) {
        if (mounted) {
          setState(() {
            // Replace text field content with recognized speech
            _controller.text = text;
            // Move cursor to end
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
        }
      });
      setState(() {
        _isListening = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
        });

        // Better error message for web users
        String errorMessage = 'Speech recognition failed';
        if (kIsWeb) {
          errorMessage = 'Microphone access denied. Click the 🔒 icon in address bar → Allow microphone';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}

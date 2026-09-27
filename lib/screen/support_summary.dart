import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/supportmessagemodel/supportmessagemodel.dart';
import 'package:flutter/material.dart';

class SupportDetailsScreen extends StatefulWidget {
  final int ticketId;
  const SupportDetailsScreen({super.key, required this.ticketId});

  @override
  State<SupportDetailsScreen> createState() => _SupportDetailsScreenState();
}

class _SupportDetailsScreenState extends State<SupportDetailsScreen> {
  // --- STATE VARIABLES ---
  bool _isLoading = true;
  String? _errorMessage;
  SupportMessageResponse? _ticketData;

  // --- CONTROLLERS ---
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSendingMessage = false;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
    _messageController.addListener(() {
      setState(() {
        _canSend = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(() {});
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetches ticket details and messages from the API
  Future<void> _loadTicketDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await AstroApiService.fetchTicketMessages(widget.ticketId);
      if (mounted) {
        setState(() {
          if (data != null && data.success) {
            _ticketData = data;
            _scrollToBottom();
          } else {
            _errorMessage = "Failed to load ticket details.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // _errorMessage = "An error occurred. Please try again.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Sends a new message to the API
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final response = await AstroApiService.submitSupportMessage(
        ticketId: widget.ticketId,
        message: _messageController.text.trim(),
      );

      if (mounted) {
        if (response != null && response.success && response.data != null) {
          setState(() {
            _ticketData!.data!.messages.add(response.data!.message);
            _messageController.clear();
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  /// Scrolls the ListView to the very bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- FIX IS HERE ---
      // This line ensures the screen content resizes and pushes up
      // when the keyboard appears, making the text field visible.
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: "Support Summary",
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
          child:
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (_ticketData == null || _ticketData!.data == null) {
      return const Center(child: Text("Could not find ticket data."));
    }

    final ticketDetails = _ticketData!.data!.ticket;
    final messages = _ticketData!.data!.messages;

    final bool isTicketClosed = ticketDetails.status.toLowerCase() == 'closed';

    return Column(
      children: [
        _TicketSummaryCard(ticket: ticketDetails),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isUserMessage = message.messageBy.toLowerCase() == 'user';
              return _MessageBubble(
                  message: message, isUserMessage: isUserMessage);
            },
          ),
        ),
        _buildMessageInput(isTicketClosed),
      ],
    );
  }

  /// Builds the message input field at the bottom
  Widget _buildMessageInput(bool isTicketClosed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2))
      ]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !isTicketClosed,
                decoration: InputDecoration(
                  hintText: isTicketClosed
                      ? "This ticket is closed"
                      : "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onSubmitted: (_) => (isTicketClosed || _isSendingMessage)
                    ? null
                    : _sendMessage(),
              ),
            ),
            const SizedBox(width: 8.0),
            _isSendingMessage
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator()),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed:
                        (isTicketClosed || !_canSend || _isSendingMessage)
                            ? null
                            : _sendMessage,
                    disabledColor: Colors.green,
                  ),
          ],
        ),
      ),
    );
  }
}

class _TicketSummaryCard extends StatelessWidget {
  final TicketDetails ticket;
  const _TicketSummaryCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ticket.ticketNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red)),
                Chip(
                  label: Text(ticket.status.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: ticket.status.toLowerCase() == 'open'
                      ? Colors.green
                      : Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow("Subject:", ticket.subject),
            _buildDetailRow("Type:", ticket.type),
            _buildDetailRow("Date", ticket.createdAt),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style:
              const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
          children: [
            TextSpan(
                text: '$title ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isUserMessage;
  const _MessageBubble({required this.message, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    final alignment =
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUserMessage ? Colors.grey.shade300 : Colors.grey.shade200;
    final bubbleRadius = isUserMessage
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16))
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16));

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(color: color, borderRadius: bubbleRadius),
          child: Text(message.message,
              style: const TextStyle(color: Colors.black87)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(message.createdAt,
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ),
      ],
    );
  }
}

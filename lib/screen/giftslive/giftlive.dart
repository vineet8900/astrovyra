import 'dart:async';
import 'package:flutter/material.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/Livegiftmodel/lifesentmodel.dart';
import 'package:astrokavach/model/Livegiftmodel/livegiftmodel.dart';
import 'package:astrokavach/screen/user_dashboard_screen/user_wallet_history_screen.dart';
import 'package:astrokavach/screen/walletupdate.dart';

class GiftsScreen extends StatefulWidget {
  final int astrologerId;
  final int liveId; // 
  // final VoidCallback onGiftSent;

  final Function(Gift sentGift) onGiftSent;

  const GiftsScreen({
    Key? key,
    required this.astrologerId,
    required this.liveId, // 
    required this.onGiftSent,
  }) : super(key: key);

  @override
  _GiftsScreenState createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen>
    with TickerProviderStateMixin {
  Future<List<Gift>?>? _giftsFuture;
  late AnimationController _animationController;

  Gift? _selectedGift;

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _giftsFuture = AstroApiService.fetchGifts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // void _handleSendGift() async {
  //   if (_selectedGift == null || _isSending) return;

  //   setState(() => _isSending = true);

  //   final SendGiftResponse? response = await AstroApiService.sendGift(
  //     giftId: _selectedGift!.id,
  //     astrologerId: widget.astrologerId,
  //   );

  //   if (mounted) {
  //     if (response != null && response.success) {
  //       Navigator.of(context).pop();
  //       _showSuccessDialog();
  //     } else {
  //       setState(() => _isSending = false);
  //     }
  //   }
  // }

  // giftslive/giftlive.dart

  void _handleSendGift() async {
    if (_selectedGift == null || _isSending) return;

    setState(() => _isSending = true);
    

    final SendGiftResponse? response = await AstroApiService.sendGift(
      giftId: _selectedGift!.id,
      astrologerId: widget.astrologerId,
      liveId: widget.liveId,
    );

    if (mounted) {
      // ====================================================================
      // YEH HAI AAPKA SOLUTION: FALSE KO HANDLE KARNE KA TARIKA
      // Hum check kar rahe hain:
      // 1. Kya response null hai? (response != null)
      // AND
      // 2. Kya `response.success` flag TRUE hai? (response.success)
      //    YA PHIR (||)
      // 3. Kya `response.message` mein "successfully" shabd likha hai?
      //    (response.message.toLowerCase().contains("successfully"))
      //
      // Inmein se koi bhi condition true hogi to hum gift ko successful manenge.
      // ====================================================================
      if (response != null &&
          (response.success ||
              response.message.toLowerCase().contains("successfully"))) {
        // TERMINAL PRINT: Ab yeh message tab bhi aayega jab success:false hoga lekin message theek hoga
        

        // Baaki ka code same rahega. Message dikhane ka logic call ho jayega.
        widget.onGiftSent(_selectedGift!);

        Navigator.of(context).pop();
        _showSuccessDialog();
      } else {
        // Yeh block ab sirf REAL errors ke liye chalega.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ??
                "Failed to send gift. Check wallet balance."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSending = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: screenWidth * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink.shade50,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "🎉 Gift Sent Successfully! 🎉",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (_selectedGift != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.pink.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          _selectedGift!.icon,
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.card_giftcard, size: 32),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedGift!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            Text(
                              "₹${_selectedGift!.price}",
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.038,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  "Your gift has been sent to the astrologer! 💝",
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Awesome! ✨",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Timer(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _animationController.value) * 300),
            child: Container(
              height: screenHeight * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildGiftGrid(screenWidth),
                  _buildFooter(screenWidth),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Send a Gift ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftGrid(double screenWidth) {
    return Expanded(
      child: FutureBuilder<List<Gift>?>(
        future: _giftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.pink.shade400,
              ),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Could not load gifts."),
            );
          }

          final List<Gift> gifts = snapshot.data!;
          final crossAxisCount = screenWidth > 900
              ? 6
              : screenWidth > 600
                  ? 5
                  : 4;

          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              final isSelected = _selectedGift?.id == gift.id;
              return _buildGiftItem(gift, isSelected, screenWidth);
            },
          );
        },
      ),
    );
  }

  Widget _buildGiftItem(Gift gift, bool isSelected, double screenWidth) {
    return GestureDetector(
      onTap: _isSending
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  _selectedGift = null;
                } else {
                  _selectedGift = gift;
                }
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.pink.shade400 : Colors.grey.shade200,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              gift.icon,
              width: screenWidth * 0.09,
              height: screenWidth * 0.09,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.card_giftcard,
                size: 30,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gift.name,
              style: TextStyle(
                fontSize: screenWidth * 0.028,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "₹${gift.price}",
              style: TextStyle(
                fontSize: screenWidth * 0.026,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(double screenWidth) {
    final bool isButtonEnabled = _selectedGift != null && !_isSending;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WalletHistoryScreen()));
            },
            icon: Icon(
              Icons.account_balance_wallet_outlined,
              size: screenWidth * 0.04,
              color: _isSending ? Colors.grey : Colors.blue.shade700,
            ),
            label: Text(
              "Recharge",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: _isSending ? Colors.grey : Colors.blue.shade700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _isSending ? Colors.grey.shade300 : Colors.blue.shade200,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              Text(
                "₹${_selectedGift?.price ?? 0}",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: _isSending ? Colors.grey : Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: isButtonEnabled ? _handleSendGift : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isSending ? Colors.grey.shade400 : Colors.pink.shade400,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "Send",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

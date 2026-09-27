import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/wishlist1/wishlist1.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Wishlistr extends StatefulWidget {
  const Wishlistr({super.key});

  @override
  State<Wishlistr> createState() => _WishlistrState();
}

class _WishlistrState extends State<Wishlistr> {
  WishlistData? _wishlistData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);

    try {
      final data = await AstroApiService.fetchWishlist();
      if (mounted) {
        setState(() {
          _wishlistData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load wishlist')),
        );
      }
    }
  }

  Future<void> _removeItemFromWishlist(WishlistItem itemToRemove) async {
    // Pehle UI se remove karo (optimistic update)
    setState(() {
      _wishlistData?.products.list.removeWhere((item) => item.wishlistId == itemToRemove.wishlistId);
      _wishlistData?.services.list.removeWhere((item) => item.wishlistId == itemToRemove.wishlistId);
    });

    // Neeche message dikhaao
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('${itemToRemove.name} removed from wishlist'),
    //     duration: const Duration(seconds: 2),
    //     backgroundColor: Colors.red[400],
    //   ),
    // );

    // Background mein API call karo
    try {
      await AstroApiService.updateWishlist(
        itemId: itemToRemove.itemId,
        action: 'remove',
      );
    } catch (e) {
      // Agar API fail ho jaye, wapas add kar do
      if (mounted) {
        setState(() {
          if (itemToRemove.runtimeType.toString().contains('Product')) {
            _wishlistData?.products.list.add(itemToRemove);
          } else {
            _wishlistData?.services.list.add(itemToRemove);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove item. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<WishlistItem> allItems = [];
    if (_wishlistData != null) {
      allItems.addAll(_wishlistData!.products.list);
      allItems.addAll(_wishlistData!.services.list);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomAppBarScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: 'wishlist'.tr,
            bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey.shade300,
          height: 1.0,
        ),
      ),
        actions: [],
      ),
      body: _buildBody(allItems),
    );
  }

  Widget _buildBody(List<WishlistItem> allItems) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Your wishlist is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        return WishlistItemCard(
          item: item,
          onRemove: () => _removeItemFromWishlist(item),
        );
      },
    );
  }
}

class WishlistItemCard extends StatefulWidget {
  final WishlistItem item;
  final VoidCallback onRemove;

  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  State<WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends State<WishlistItemCard> {
  bool _isRemoving = false;

  void _handleRemove() {
    setState(() => _isRemoving = true);
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isRemoving ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Card(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  widget.item.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: ₹${widget.item.salePrice}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isRemoving ? Icons.favorite_border : Icons.favorite,
                  color: _isRemoving ? Colors.grey : Colors.red,
                ),
                onPressed: _isRemoving ? null : _handleRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
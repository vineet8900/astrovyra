import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/transactionhistory/transactionhistory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Transactionhistory extends StatefulWidget {
  const Transactionhistory({super.key});

  @override
  State<Transactionhistory> createState() => _TransactionhistoryState();
}

class _TransactionhistoryState extends State<Transactionhistory> {
  final List<WalletTransaction> _transactions = [];

  bool _isLoading = false;
  bool _isInitialLoad = true;
  int _currentPage = 1;
  int _maxDiscoveredPage = 1; // Maximum page we've discovered so far
  bool _hasMorePages = true;
  Set<int> _availablePages = {1}; // Pages we know exist

  @override
  void initState() {
    super.initState();

    _fetchHistory();
  }

  Future<void> _fetchHistory({int? specificPage}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    int pageToFetch = specificPage ?? _currentPage;

    WalletHistoryResponse? response =
        await AstroApiService.fetchWalletHistory(page: pageToFetch);

    if (mounted) {
      if (response != null && response.success && response.data != null) {
        setState(() {
          _transactions.clear();
          _transactions.addAll(response.data!.list);

          _currentPage = pageToFetch;
          _hasMorePages = response.data!.hasMorePages;

          _availablePages.add(_currentPage);

          if (_currentPage > _maxDiscoveredPage) {
            _maxDiscoveredPage = _currentPage;
          }

          if (_hasMorePages) {
            _availablePages.add(_currentPage + 1);
            _maxDiscoveredPage = _currentPage + 1;
          }
        });
      } else {
        setState(() {
          _hasMorePages = false;
          // Remove any pages beyond current if they don't exist
          _availablePages.removeWhere((page) => page > _currentPage);
          _maxDiscoveredPage = _currentPage;
        });
      }

      setState(() {
        _isLoading = false;
        _isInitialLoad = false;
      });
    }
  }

  /// Specific page load karne ke liye
  void _loadPage(int page) {
    if (page != _currentPage && page > 0 && _availablePages.contains(page)) {
      _fetchHistory(specificPage: page);
    }
  }

  /// Previous page
  void _loadPreviousPage() {
    if (_currentPage > 1) {
      _loadPage(_currentPage - 1);
    }
  }

  /// Next page
  void _loadNextPage() {
    if (_hasMorePages && _availablePages.contains(_currentPage + 1)) {
      _loadPage(_currentPage + 1);
    }
  }

  /// Refresh data
  Future<void> _refreshData() async {
    setState(() {
      _currentPage = 1;
      _maxDiscoveredPage = 1;
      _hasMorePages = true;
      _availablePages = {1};
      _transactions.clear();
    });
    await _fetchHistory(specificPage: 1);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomAppBarScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BottomAppBarScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: 'transactionHistory'.tr,
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  /// Main body UI
  Widget _buildBody() {
    if (_isInitialLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No transactions found.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Page info
        // _buildPageInfo(),

        // Transaction list
        Expanded(child: _buildTransactionList()),

        // Pagination controls
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          final isDebit = transaction.action.toLowerCase() == 'debit';

          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isDebit ? Colors.red.shade100 : Colors.green.shade100,
                child: Icon(
                  isDebit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isDebit ? Colors.red.shade700 : Colors.green.shade700,
                  size: 22,
                ),
              ),
              title: Text(
                transaction.remark,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  transaction.dateTime,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
              trailing: Text(
                '${isDebit ? '-' : '+'} ₹${transaction.amount}',
                style: TextStyle(
                  color: isDebit ? Colors.red.shade800 : Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Pagination controls with numbered buttons
  Widget _buildPaginationControls() {
    if (_availablePages.length <= 1 && !_hasMorePages)
      return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            IconButton(
              onPressed: _currentPage > 1 ? _loadPreviousPage : null,
              icon: const Icon(Icons.chevron_left),
              style: IconButton.styleFrom(
                backgroundColor: _currentPage > 1
                    ? CustomStyles.ctaColor
                    : Colors.grey.shade200,
                foregroundColor:
                    _currentPage > 1 ? CustomStyles.whiteColor : Colors.grey,
              ),
            ),

            const SizedBox(width: 8),

            // Page numbers
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageNumbers(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Next button
            IconButton(
              onPressed: _hasMorePages ? _loadNextPage : null,
              icon: const Icon(Icons.chevron_right),
              style: IconButton.styleFrom(
                backgroundColor: _hasMorePages
                    ? CustomStyles.ctaColor
                    : Colors.grey.shade200,
                foregroundColor: _hasMorePages ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generate page number buttons
  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];

    // Sort available pages
    List<int> sortedPages = _availablePages.toList()..sort();

    // Show all available pages if they're not too many
    if (sortedPages.length <= 7) {
      for (int page in sortedPages) {
        pageButtons.add(_buildPageButton(page));
      }

      // If there are more pages available, show next page button
      if (_hasMorePages && !_availablePages.contains(_currentPage + 1)) {
        pageButtons.add(_buildNextPageDiscoveryButton());
      }
    } else {
      // Too many pages, show smart pagination
      pageButtons = _buildSmartPagination(sortedPages);
    }

    return pageButtons;
  }

  /// Build smart pagination when there are many pages
  List<Widget> _buildSmartPagination(List<int> sortedPages) {
    List<Widget> pageButtons = [];

    // Always show first page
    pageButtons.add(_buildPageButton(1));

    // Show pages around current page
    List<int> nearbyPages = sortedPages
        .where((page) => (page - _currentPage).abs() <= 2 && page != 1)
        .toList();

    if (nearbyPages.isNotEmpty) {
      if (nearbyPages.first > 2) {
        pageButtons.add(_buildEllipsis());
      }

      for (int page in nearbyPages) {
        pageButtons.add(_buildPageButton(page));
      }
    }

    // Show next page discovery button if needed
    if (_hasMorePages && !_availablePages.contains(_currentPage + 1)) {
      pageButtons.add(_buildNextPageDiscoveryButton());
    }

    return pageButtons;
  }

  /// Button to discover next page
  Widget _buildNextPageDiscoveryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () {
          int nextPage = _currentPage + 1;
          _fetchHistory(specificPage: nextPage);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade400),
          ),
          child: Center(
            child: Text(
              '${_currentPage + 1}',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Individual page button
  Widget _buildPageButton(int page) {
    final isCurrentPage = page == _currentPage;
    final isClickable = _availablePages.contains(page);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: isClickable ? () => _loadPage(page) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrentPage
                ? CustomStyles.pinki
                : isClickable
                    ? Colors.transparent
                    : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrentPage
                  ? Colors.blue.shade600
                  : isClickable
                      ? Colors.grey.shade400
                      : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              '$page',
              style: TextStyle(
                color: isCurrentPage
                    ? Colors.white
                    : isClickable
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Ellipsis (...) for skipped pages
  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

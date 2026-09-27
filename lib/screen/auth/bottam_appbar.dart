// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:jyotish_setu/custom_widgets/styles.dart';
// import 'package:jyotish_setu/screen/astrologer/home_screen.dart';
// // ignore: must_be_immutable
// class BottomAppBarScreen extends StatefulWidget {
//   int bottambarindex;
//   dynamic lawyercategory;
//   bool? leadingbtn;
//   final String? courseSlug;
//   final String? productCategorySlug;

//   BottomAppBarScreen({
//     Key? key,
//     this.bottambarindex = 0,
//     this.courseSlug,
//     this.productCategorySlug,
//     this.leadingbtn = false,this.lawyercategory
//   }) : super(key: key);

//   @override
//   _BottomAppBarScreenState createState() => _BottomAppBarScreenState();
// }

// class _BottomAppBarScreenState extends State<BottomAppBarScreen> {
//   DateTime? lastBackPressed;
//   List<Widget> get _screens {
//     return [
//       HomeScreen(),
//       HireLawyerScreen(leadingbtn: widget.leadingbtn),
//       ConsultationListScreen(leadingbtn: widget.leadingbtn,lawyercategory:  widget.lawyercategory,),
//       ProductCategoryListScreen(leadingbtn: widget.leadingbtn),
//       QuestionMainScreen(leadingbtn: widget.leadingbtn),
//     ];
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       widget.bottambarindex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//     onWillPop: () async {
//       if (widget.bottambarindex != 0) {
//         setState(() {
//           widget.bottambarindex = 0; 
//         });
//         return false;
//       }

//       DateTime now = DateTime.now();
//       if (lastBackPressed == null || now.difference(lastBackPressed!) > Duration(seconds: 2)) {
//         lastBackPressed = now;
//        Fluttertoast.showToast(
//           msg: "Press back again to exit",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.black87,
//           textColor: Colors.white,
//         );
//         return false;
//       }
//       return true; 
//     },
//       child: Scaffold( 
//          backgroundColor: Colors.white,
      
//         body: Column(
//           children: [
//             Expanded(child: _screens[widget.bottambarindex]), 
//           ],
//         ),
      
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//         floatingActionButton: FloatingActionButton(
//           shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
//           onPressed: () {
//             _onItemTapped(2);
//           },
//           backgroundColor: CustomStyles.bgcolor,
//           child: Image.asset(
//             "assets/mic.png",
//             scale: 5,
//             color: Colors.white,
//           ),
//         ),
      
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: widget.bottambarindex,
//           backgroundColor: CustomStyles.bgcolor,
//           elevation: 10,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white,
//           selectedLabelStyle: CustomStyles.black13600,
//           unselectedLabelStyle: CustomStyles.black12400,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           onTap: _onItemTapped,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home, color: Colors.white),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: ImageIcon(AssetImage("assets/lawyer.png")),
//               label: 'Lawyers',
//             ),
//             BottomNavigationBarItem(
//               icon: SizedBox.shrink(),
//               label: '',
//             ),
//             BottomNavigationBarItem(
//               icon: ImageIcon(AssetImage("assets/product.png")),
//               label: 'Product',
//             ),
//             BottomNavigationBarItem(
//               icon: ImageIcon(AssetImage("assets/question.png")),
//               label: 'Questions',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

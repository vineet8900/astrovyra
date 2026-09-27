import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';

import 'package:rating_summary/rating_summary.dart';

class PoojaDetailScreen extends StatelessWidget {
  const PoojaDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Pooja Details"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/product.png"),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: Text(
                    "11,000 Maha Mrityunjaya Mantra Jaap",
                    style: CustomStyles.black16600,
                    maxLines: 2,
                  )),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.favorite_outline,
                    color: CustomStyles.bgredcolor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.share_sharp,
                    color: Colors.deepOrange,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "₹1499",
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text("₹999", style: CustomStyles.black16600),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.",
                style: CustomStyles.black14500,
              ),
              SizedBox(height: 10),
              ListView.builder(
                  itemCount: 3,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Theme(
                          data: ThemeData(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: false,
                            backgroundColor: CustomStyles.bgcolor,
                            collapsedBackgroundColor: Colors.yellow.shade50,
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            tilePadding: EdgeInsets.symmetric(horizontal: 10),
                            childrenPadding: EdgeInsets.zero,
                            title: Text(
                              'what are the benefits',
                              style: CustomStyles.black13600,
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.black,
                            ),
                            onExpansionChanged: (expanded) {
                              // setState(() {
                              //   _isExpanded[index] = expanded;
                              // });
                            },
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white),
                                child: Text(
                                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvina",
                                  style: CustomStyles.grey12400,
                                ),
                              )
                            ],
                          )),
                    );
                  }),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Rating and Reviews (${3})",
                    style: CustomStyles.black14600,
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Only ratings from verified purchases are included in the final evalution.",
                      style: CustomStyles.black12500,
                    )),
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RatingSummary(
                        counter: 4,
                        average: 3.5,
                        showAverage: false,
                        counterFiveStars: 5,
                        counterFourStars: 4,
                        counterThreeStars: 3,
                        counterTwoStars: 2,
                        counterOneStars: 1,
                        labelStyle: CustomStyles.red13500,
                        backgroundColor: Colors.grey,
                        color: CustomStyles.bgcolor,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("5"),
                          RatingBarIndicator(
                            rating: 2.4,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: CustomStyles.bgcolor,
                            ),
                            itemCount: 5,
                            itemSize: 18,
                            direction: Axis.horizontal,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Customers review",
                  style: CustomStyles.black14600,
                ),
              ),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 10, top: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      "https://randomuser.me/api/portraits/men/31.jpg"),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Shivani",
                                        style: CustomStyles.black13600,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2),
                                      RatingBarIndicator(
                                        rating: 3,
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Color(0xffFFAF12),
                                        ),
                                        itemCount: 5,
                                        itemSize: 18,
                                        direction: Axis.horizontal,
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '4-june-2001',
                                        style: CustomStyles.black12500,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  "nunc felis bibendum nunc facilisis in ullamcorper vivamus is bibendum nunc.nunc felis bibendum nunc facilisis in ullamcorper vivamus is bibendum nunc.",
                                  style: CustomStyles.black12500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Upcoming Pooja ",
                  style: CustomStyles.black14600,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemExtent: 280,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 250,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 150,
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      "https://images.pexels.com/photos/6765631/pexels-photo-6765631.jpeg"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: CustomStyles.bgcolor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  "Remove Insecurities and Attractive love",
                                  style: CustomStyles.black12500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Ganesh Ji ko Laddoo Arpan",
                                      style: CustomStyles.grey14600),
                                  Text(
                                    "Mrityunjay Mahadev Mandir, Varanasi",
                                    style: CustomStyles.grey12400,
                                    maxLines: 1,
                                  ),
                                  Divider(
                                    color: Colors.grey.shade300,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Apr 26, 2025, 10:00 AM",
                                                  style:
                                                      CustomStyles.grey12400),
                                              Text("₹1499",
                                                  style: CustomStyles.red15600),
                                            ],
                                          ),
                                          Spacer(),
                                          Expanded(
                                            child: GFButton(
                                              onPressed: () {},
                                              text: "Book",
                                              color: Colors.red,
                                              textStyle:
                                                  CustomStyles.white12500,
                                              shape: GFButtonShape.standard,
                                              fullWidthButton: false,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              size: 25.8,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: GFButton(
                onPressed: () {},
                text: "Add to Cart",
                color: Colors.red,
                textStyle: CustomStyles.white,
                shape: GFButtonShape.pills,
                fullWidthButton: false,
                padding: EdgeInsets.symmetric(horizontal: 10),
                size: 45.8,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: GFButton(
                onPressed: () {},
                text: "Book Now",
                color: Colors.red,
                textStyle: CustomStyles.white,
                shape: GFButtonShape.pills,
                fullWidthButton: false,
                padding: EdgeInsets.symmetric(horizontal: 10),
                size: 45.8,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

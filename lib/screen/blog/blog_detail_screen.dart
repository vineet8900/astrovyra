import 'package:astrokavach/api/blog_api/blog_Detail_Api.dart';
import 'package:astrokavach/api/blog_api/blog_list_api.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/blog_model/blog_detail_model.dart';
import 'package:astrokavach/model/blog_model/blog_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetailScreen extends StatefulWidget {
  int? blogid;
  BlogDetailScreen({super.key, this.blogid});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  ReusableFunction reusableFunction = ReusableFunction();
  bool isloading = false;

  BlogListApi relatedblogListApi = BlogListApi();
  BlogListModel? relatedblogListModel;
  List<BlogList> relatedbloglist = [];

  BlogDetailApiService blogDetailApiService = BlogDetailApiService();
  BlogDetailApiModel? blogDetailApiModel;

  Widget _blogGridCard(BuildContext context, BlogList blog) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              blog.image ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.45),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    blog.title ?? '',
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if ((blog.category ?? '').isNotEmpty)
                        blog.category!.trim(),
                      if ((blog.postedOn ?? '').isNotEmpty)
                        blog.postedOn!.trim(),
                    ].join(' • '),
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((blog.subTitle ?? '').toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      blog.subTitle.toString().trim(),
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 11 : 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getProductDetailListData() async {
    setState(() {
      isloading = true;
    });
    try {
      blogDetailApiModel =
          await blogDetailApiService.fetchBlogDetail(widget.blogid);
      relatedblogListModel = await relatedblogListApi.fetchBolgApidata(
          blogDetailApiModel!.data!.category!.id, widget.blogid ?? 0, 0, 1);
      relatedbloglist = relatedblogListModel?.data?.list ?? [];
    } catch (e) {
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductDetailListData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.03;
    final gridSpacing = screenWidth < 600 ? 10.0 : 12.0;
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final cardWidth = (availableWidth - gridSpacing) / 2;
    final cardHeight = screenWidth < 600
        ? screenHeight * 0.14
        : screenWidth < 900
            ? screenHeight * 0.16
            : screenHeight * 0.18;

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: "Blog Title",
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: isloading && blogDetailApiModel == null
          ? reusableFunction.loadingRow()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              blogDetailApiModel?.data?.image ?? ''),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Row(
                    //   children: [
                    //     Expanded(child: Text(

                    //       '',style: CustomStyles.black16600,maxLines: 2,)),SizedBox(width: 10,),
                    //     //  Icon(Icons.favorite_outline,color: CustomStyles.bgredcolor,),SizedBox(width: 10,), Icon(Icons.share_sharp,color: CustomStyles.bgredcolor,),
                    //   ],
                    // ),

                    Row(
                      children: [
                        Text(
                          blogDetailApiModel?.data?.title ?? '',
                          style: CustomStyles.black16600,
                        ),
                        Spacer(),
                        Text(blogDetailApiModel?.data?.postedOn ?? '',
                            style: CustomStyles.grey14400),
                      ],
                    ),
                    SizedBox(height: 10),
                    HtmlWidget(
                      blogDetailApiModel?.data?.description ?? '',
                      textStyle: CustomStyles.black14500,
                      customStylesBuilder: (element) {
                        switch (element.localName) {
                          case 'h1':
                            return {
                              'font-size': '18px',
                              'font-weight': '600',
                              'margin': '0',
                              'padding': '0'
                            };
                          case 'h2':
                            return {
                              'font-size': '16px',
                              'font-weight': '700',
                              'margin': '0',
                              'padding': '0'
                            };
                          case 'h3':
                            return {
                              'font-size': '14px',
                              'font-weight': '700',
                              'margin': '0',
                              'padding': '0'
                            };
                          case 'h4':
                            return {
                              'font-size': '14px',
                              'font-weight': '600',
                              'margin': '0',
                              'padding': '0'
                            };
                          case 'h5':
                            return {
                              'font-size': '12px',
                              'margin': '0',
                              'padding': '0'
                            };
                          case 'h6':
                            return {
                              'font-size': '10px',
                              'margin': '0',
                              'padding': '0'
                            };
                          default:
                            return null;
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    //  Padding(
                    //              padding: const EdgeInsets.only(bottom: 10),
                    //              child: Theme(
                    //                data: ThemeData(dividerColor: Colors.transparent),
                    //                child: ExpansionTile(
                    //                  initiallyExpanded: false,
                    //                  backgroundColor: CustomStyles.bgcolor,
                    //                  collapsedBackgroundColor: Colors.yellow.shade50,
                    //                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    //                  iconColor: Colors.white,
                    //                  collapsedIconColor: Colors.white,
                    //                  tilePadding: EdgeInsets.symmetric(horizontal: 10),
                    //                  childrenPadding: EdgeInsets.zero,

                    //                  title: Text(
                    //                   'Description',
                    //                    style: CustomStyles.black13600,
                    //                  ),

                    //                  trailing: Icon(
                    //                        Icons.keyboard_arrow_up,color: Colors.black,),
                    //              onExpansionChanged: (expanded) {
                    //                    // setState(() {
                    //                    //   _isExpanded[index] = expanded;
                    //                    // });
                    //                  },

                    //                  children: [
                    //                    Container(width: MediaQuery.of(context).size.width,
                    //                      padding: EdgeInsets.all(10),
                    //                      decoration: BoxDecoration(color: Colors.white),
                    //                      child: Text(
                    //                                               "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvina",

                    //                        style: CustomStyles.grey12400,
                    //                      ),
                    //                    )
                    //                  ],
                    //               )),
                    //            ),

                    relatedbloglist.isEmpty
                        ? SizedBox()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Related Blog ",
                              style: CustomStyles.black16600,
                            ),
                          ),
                    SizedBox(
                      height: 5,
                    ),
                    if (relatedbloglist.isNotEmpty)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: relatedbloglist.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: gridSpacing,
                            mainAxisSpacing: gridSpacing,
                            childAspectRatio: cardWidth / cardHeight,
                          ),
                          itemBuilder: (context, index) {
                            final blog = relatedbloglist[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlogDetailScreen(
                                      blogid: blog.id,
                                    ),
                                  ),
                                );
                              },
                              child: _blogGridCard(context, blog),
                            );
                          },
                        ),
                      ),

                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

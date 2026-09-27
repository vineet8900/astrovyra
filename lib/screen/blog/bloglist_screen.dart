import 'package:astrokavach/api/blog_api/blog_category_api.dart';
import 'package:astrokavach/api/blog_api/blog_list_api.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/blog_model/blog_category_model.dart';
import 'package:astrokavach/model/blog_model/blog_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'blog_detail_screen.dart';

class BloglistScreen extends StatefulWidget {
  BloglistScreen({super.key});

  @override
  State<BloglistScreen> createState() => _BloglistScreenState();
}

class _BloglistScreenState extends State<BloglistScreen> {
  bool isloading = false;
  bool isMoreDataAvailable = true;
  int currentPage = 1;

  final ReusableFunction reusableFunction = ReusableFunction();
  final BlogCategoryApi blogCategoryApi = BlogCategoryApi();
  final BlogListApi blogListApi = BlogListApi();

  BlogCategoryModel? blogCategoryModel;
  BlogListModel? blogListModel;
  List<BlogList> bloglist = [];

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getBlogData();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isloading &&
          isMoreDataAvailable) {
        getBlogData();
      }
    });
  }

  Future<void> getBlogData() async {
    if (!isloading && isMoreDataAvailable) {
      setState(() => isloading = true);

      await Future.delayed(const Duration(milliseconds: 300));

      blogListModel = await blogListApi.fetchBolgApidata(0, 0, 0, currentPage);

      if (blogListModel?.data?.list != null &&
          blogListModel!.data!.list!.isNotEmpty) {
        bloglist.addAll(blogListModel!.data!.list!);
        currentPage++;
      } else {
        isMoreDataAvailable = false;
      }

      setState(() => isloading = false);
    }
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
        title: 'blogs'.tr,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: isloading && bloglist.isEmpty
            ? reusableFunction.loadingRow()
            : SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenHeight * 0.01,
                ),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bloglist.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemBuilder: (context, index) {
                        final blog = bloglist[index];
                        return GestureDetector(
                          onTap: () =>
                              Get.to(BlogDetailScreen(blogid: blog.id)),
                          child: Container(
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
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
                                            fontSize:
                                                screenWidth < 600 ? 14 : 16,
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
                                            if ((blog.category ?? '')
                                                .isNotEmpty)
                                              blog.category!.trim(),
                                            if ((blog.postedOn ?? '')
                                                .isNotEmpty)
                                              blog.postedOn!.trim(),
                                          ].join(' • '),
                                          style: TextStyle(
                                            fontSize:
                                                screenWidth < 600 ? 11 : 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.yellow,
                                            height: 1.1,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if ((blog.subTitle ?? '')
                                            .toString()
                                            .trim()
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            blog.subTitle.toString().trim(),
                                            style: TextStyle(
                                              fontSize:
                                                  screenWidth < 600 ? 11 : 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white
                                                  .withOpacity(0.85),
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
                          ),
                        );
                      },
                    ),
                    if (isloading && isMoreDataAvailable)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

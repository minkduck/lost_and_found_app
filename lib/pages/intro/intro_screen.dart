import 'package:flutter/material.dart';
import 'package:lost_and_find_app/pages/home_login_page.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();

}

class _IntroPageState extends State<IntroPage> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: controller,
          onPageChanged: (index){
            setState(()=> isLastPage = index ==2);
          },// Connect the PageController to PageView
          children: [

            buildPage(
                color: Theme.of(context).cardColor,
                urlImage: AppAssets.recover,
                title: 'RECOVER',
                subtitle: 'Easily turn in found items and assist others in their search.', context: context
            ),
            buildPage(
                color: Theme.of(context).cardColor,
                urlImage: AppAssets.reconnect,
                title: 'RECONNECT',
                subtitle: 'Reconnect people with their lost items. ', context: context
            ),
            buildPage(
                color: Theme.of(context).cardColor,
                urlImage: AppAssets.revive,
                title: 'REVIVE',
                subtitle: 'Revive the hope of finding lost belongings. ', context: context
            ),
          ],
        ),
      ),
      bottomSheet: isLastPage?TextButton(style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          primary: Colors.white,
          backgroundColor: AppColors.primaryColor,
          minimumSize: const Size.fromHeight(80)
      ),onPressed: () async{
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('showHome', true);

        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> HomeLoginPage()),
        );
      },
          child: const Text('Get Started', style: TextStyle(fontSize: 24),)):Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => controller.jumpToPage(2),
              child: Text('SKIP', style: TextStyle(
                color: AppColors.primaryColor
              ),),
            ),
            Center(
              child: SmoothPageIndicator(
                controller: controller, // Connect the PageController to SmoothPageIndicator
                count: 3,
                effect: WormEffect(
                  spacing: 16,
                  dotColor: Colors.black26,
                  activeDotColor: AppColors.primaryColor,
                ),
                onDotClicked: (index) => controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
              child: Text('NEXT', style: TextStyle(
                  color: AppColors.primaryColor
              )),
            ),
          ],
        ),
      ),
    );
  }


}

Widget buildPage({
  required BuildContext context, // Add BuildContext as an argument
  required Color color,
  required String urlImage,
  required String title,
  required String subtitle,
}) => Container(
  color: color,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(urlImage, fit: BoxFit.cover, width: double.infinity),
      const SizedBox(height: 64),
      Text(
        title,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Text(
          subtitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18),
        ),
      ),
    ],
  ),
);

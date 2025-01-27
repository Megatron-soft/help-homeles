import 'package:flutter/material.dart';
import 'package:shelter/helper/helper.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          CacheHelper.getData(key: "lang") == "ar" ? 'About Us' : "نبذه عنا",
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CacheHelper.getData(key: "lang") == "ar"
                  ? "Welcome to Help Homeless"
                  : "اهلا بك في ساعد المحتاج",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              CacheHelper.getData(key: "lang") == "ar"
                  ? "Our mission is to connect communities to help homeless people in need."
                  : "مهمتنا هي ربط المجتمعات لمساعدة المشردين المحتاجين.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              CacheHelper.getData(key: "lang") == "ar"
                  ? "How You Can Help:"
                  : "كيف تساعد:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              CacheHelper.getData(key: "lang") == "ar"
                  ? "- Share resources like food, clothing, and shelter.\n- Report locations of people in need.\n- Volunteer or donate through the app."
                  : "- تقاسم موارد مثل الطعام والملابس والمأوى.\n- ابلاغ عن اماكن وجود المحتاجين.\n- تطوع أو تبرع عبر التطبيق.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              CacheHelper.getData(key: "lang") == "ar"
                  ? "Thank you for joining us in making a difference."
                  : "شكرا لانضمامك الينا في صنع فارق.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

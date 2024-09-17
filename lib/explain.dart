import 'package:flutter/material.dart';

class Explain extends StatefulWidget {
  const Explain({super.key});

  @override
  State<Explain> createState() => _ExplainState();
}

class _ExplainState extends State<Explain> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          _buildPage(
            title: 'ようこそ！',
            subtitle: '「アプリ名」にようこそ。',
            content: 'このアプリで覚えたいことを暗記してハピネスを貯めましょう！',
            imagePath: 'assets/images/mainIcon.png',
            pageNumber: '1 / 6',
            isLastPage: false,
          ),
          _buildPage(
            title: '使い方',
            subtitle: '使い方①',
            content: 'まずは覚えたいことを入力しましょう！',
            imagePath: 'assets/images/1.png',
            pageNumber: '2 / 6',
            isLastPage: false,
          ),
          _buildPage(
            title: '使い方',
            subtitle: '使い方②',
            content: '入力した項目は全てALLページに表示されます',
            imagePath: 'assets/images/2.png',
            pageNumber: '3 / 6',
            isLastPage: false,
          ),
          _buildPage(
            title: '使い方',
            subtitle: '使い方③',
            content: '一定時間経過するとTopページに暗記カードが出現します。暗記するごとにハピネスがたまり、画面左上に表示されます！',
            imagePath: 'assets/images/3.png',
            pageNumber: '4 / 6',
            isLastPage: false,
          ),
          _buildPage(
            title: '使い方',
            subtitle: '使い方④',
            content: 'ハピネスを消費することでストーリーが進みます！',
            imagePath: 'assets/images/4.png',
            pageNumber: '5 / 6',
            isLastPage: false,
          ),
          _buildPage(
            title: '開始する',
            subtitle: 'さあ、始めましょう！',
            content: 'これで準備完了です。アプリの使用を開始しましょう！',
            imagePath: 'assets/images/mainIcon.png',
            pageNumber: '6 / 6',
            isLastPage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required String content,
    required String imagePath,
    required String pageNumber,
    required bool isLastPage,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purpleAccent, Colors.deepPurple, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono',
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 90.0),
            imagePath.isNotEmpty
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.none,
                  )
                : SizedBox(height: 300),
            SizedBox(height: 20.0),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
                fontFamily: 'RobotoMono',
                shadows: [
                  Shadow(
                    blurRadius: 8.0,
                    color: Colors.black.withOpacity(0.4),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white60,
                fontFamily: 'RobotoMono',
                shadows: [
                  Shadow(
                    blurRadius: 6.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            if (isLastPage)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
                  elevation: 10.0,
                ),
                child: Text(
                  '開始',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                pageNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontFamily: 'RobotoMono',
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

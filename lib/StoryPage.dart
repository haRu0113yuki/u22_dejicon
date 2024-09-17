import 'package:flutter/material.dart';
import 'globals.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  List<bool> unlockedStories = List.filled(13, false);

  final List<int> storyCosts = [
    2,
    11,
    37,
    89,
    131,
    523,
    1027,
    4019,
    8291,
    15937,
    30031,
    60149,
    111117
  ];

  @override
  void initState() {
    super.initState();
  }

  void _unlockStory(int index) {
    int cost = storyCosts[index];

    if (happinessCount >= cost) {
      setState(() {
        happinessCount -= cost;
        unlockedStories[index] = true;
      });
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('ハピネス不足'),
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('ストーリーを解放するためのハピネスが足りません。'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ストーリー'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/mainIcon.png',
                  width: 36,
                  height: 36,
                ),
                const SizedBox(width: 8),
                Text(
                  '$happinessCount',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black12,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 13,
        itemBuilder: (context, index) {
          return Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '第 ${index + 1} 章 　　　　　 ',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    TextSpan(
                      text: '${storyCosts[index]} ハピネス',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            unlockedStories[index] ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: unlockedStories[index]
                  ? const Icon(Icons.lock_open, color: Colors.green, size: 30)
                  : const Icon(Icons.lock, color: Colors.red, size: 30),
              onTap: () {
                if (unlockedStories[index]) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryDetailPage(index: index),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text('ストーリーを解放'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'このストーリーを解放するために${storyCosts[index]} ハピネスを消費しますか？',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('いいえ'),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  _unlockStory(index);
                                },
                                child: const Text('はい'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

final List<Map<String, String>> storyContents = [
  {
    'title': '第 1 章 幸福の追求',
    'content':
        '第1章: 幸福の追求\n\n\n序: 神秘の扉\n\n\n青年リュウは、どこにあるのかもわからない「幸福」を探し求めていた。ある朝、草原にぽつんと立つ扉を見つける。噂によれば、その扉の向こうには幸福を示す地図があるという。リュウは好奇心と期待を胸に、その扉に手をかけた。\n\n\n1: 時の迷路\n\n\n扉を開けると、そこには古代ギリシャ風の街並みと巨大な迷路が広がっていた。迷路の中央で、リュウは三人の賢者に出会う。ソクラテスは「幸福は自分を知ることから始まる」と語り、リュウは自分自身を見つめ直す旅に出ることに。\n\n次に出会ったのはプラトンで、「真の幸福は物質ではなく、精神的な真実から生まれる」と教えられたリュウは、物質を超えた精神的な豊かさを追い求めるようになる。\n\nアリストテレスの「善の庭園」では、「善い行いが幸福を生む」と説かれ、リュウは行いがもたらす喜びを実感する。\n\n\n2: 神話の星空\n\n\n次に、リュウは古代エジプトの「神話の星空」に辿り着く。星々が織りなす物語の中で、オシリス神の復活の話を聞きながら、幸福が生と死を超えるものであることを悟る。\n\nイシスの星座の下では、愛が幸福をもたらすことを学び、リュウは愛の力を感じ取る。\n\n\n3: 中世の秘密の庭\n\n\nリュウの旅は、中世ヨーロッパの「秘密の庭」に続く。トマス・アクィナスの庭で「幸福は神との結びつきにある」と説かれ、その果実を一口噛むことで、神との深い関係が幸福の源であると感じる。\n\nアウグスティヌスの庭には「愛の泉」が流れ、その水が幸福をもたらすことを学んだリュウは、愛の泉から飲むことで精神的な満足が幸福に不可欠であると実感する。\n\n\n4: 現代のハピネスランド\n\n\nリュウが旅の終わりに辿り着いたのは、現代の「ハピネスランド」。ここでは、ポジティブ心理学のアトラクションパークで、ポジティブな感情や良好な人間関係が幸福をどう形成するかを体験する。\n\nまた、エイミー・チュアの「コミュニティフェスティバル」に参加し、社会的なつながりやコミュニティが幸福にどう影響するかを学び、友人や家族との絆の重要性を理解する。\n\n\n終: 幸福の地図\n\n\nリュウは長い旅を終え、幸福の地図が単なる答えではなく、自分自身の価値観や信念に基づいて探し続けるものであることを知る。幸福は自己認識や愛、倫理、精神的なつながり、社会的なつながりなど、多くの要素から成り立っている\n\n\n「幸せの扉」の前に立ち、これからの人生に新たな光をもたらす決意を固めるリュウ。その扉を閉じながら、幸福の探求が終わることなく続くことを確信するのだった。',
    'image': 'assets/images/chapter1_image.png',
  },
  {
    'title': '第 2 章 タイトル',
    'content': '第 2 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter2_image.png',
  },
  {
    'title': '第 3 章 タイトル',
    'content': '第 3 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter3_image.png',
  },
  {
    'title': '第 4 章 タイトル',
    'content': '第 4 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter4_image.png',
  },
  {
    'title': '第 5 章 タイトル',
    'content': '第 5 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter5_image.png',
  },
  {
    'title': '第 6 章 タイトル',
    'content': '第 6 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter6_image.png',
  },
  {
    'title': '第 7 章 タイトル',
    'content': '第 7 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter7_image.png',
  },
  {
    'title': '第 8 章 タイトル',
    'content': '第 8 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter8_image.png',
  },
  {
    'title': '第 9 章 タイトル',
    'content': '第 9 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter9_image.png',
  },
  {
    'title': '第 10 章 タイトル',
    'content': '第 10 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter10_image.png',
  },
  {
    'title': '第 11 章 タイトル',
    'content': '第 11 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter11_image.png',
  },
  {
    'title': '第 12 章 タイトル',
    'content': '第 12 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter12_image.png',
  },
  {
    'title': '第 13 章 タイトル',
    'content': '第 13 章の本文がここに表示されます。内容は長文にしてもスクロールできるようになります。',
    'image': 'assets/images/chapter13_image.png',
  }
];

class StoryDetailPage extends StatelessWidget {
  final int index;

  const StoryDetailPage({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chapter = storyContents[index];

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter['title'] ?? '第 ${index + 1} 章'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter['title'] ?? '第 ${index + 1} 章',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 30.0),
            Text(
              chapter['content'] ?? 'ここにストーリーの内容が表示されます。',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 30.0),
            Image.asset(
              chapter['image'] ?? 'assets/images/default_image.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(loginFormApp);

var loginFormApp = ChangeNotifierProvider(
  create: (context) => SimpleState(),
  child: MyApp(),
);


//전역변수 관련
class SimpleState with ChangeNotifier {
  
  late String octitle='';
  late String ocscore='';
  late String octext='';
  int number = 0;
  //별점을 매길 대상의 이름, 점수, 한줄평을 저장할 String 변수와
  //해당 대상이 몇번째인지 나타낼 number 변수
  
  int get numb => number;
  void setnbs(int cn){number = cn; notifyListeners();}
  void settitle(String title) {octitle = title; notifyListeners();}
  String get title => octitle;
  void setscore(String score) {ocscore = score;notifyListeners();}
  String get score => ocscore;
  void settext(String text) {octext = text;notifyListeners();}
  String get text => octext;
  //변수들 getter, setter
  
  void deltitle(int n) {ltitle.removeAt(n); notifyListeners();}
  void delscore(int n) {lscore.removeAt(n); notifyListeners();}
  void deltext(int n) {ltext.removeAt(n); number-=1; notifyListeners();}
  //삭제 담당 메서드
  
  List<String> ltitle = ['NULL'];
  List<String> lscore = ['NULL'];
  List<String> ltext = ['NULL'];
  List get lt => ltitle;
  List get ls => lscore;
  List get ltx => ltext;
  //별점을 매긴 대상들의 이름, 점수, 한줄평을 차례대로 저장하는 string list
  
  Future<void> setlist(String title, String score, String text) async {
    if(int.parse(score) is int) {
      number += 1;
      ltitle.add(octitle);
      lscore.add(ocscore);
      ltext.add(octext);
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('mtdata', ltitle);
      prefs.setStringList('msdata', lscore);
      prefs.setStringList('mtxdata', ltext);
      prefs.setInt('nums', number);
    }
  }
  //기기에 저장된 데이터를 가져오는 메서드
  
  void jsonlist(List<String> ls1, List<String> ls2, List<String> ls3){
    ltitle = ls1;
    lscore = ls2;
    ltext = ls3;
  }
  //setlist로 가져온 데이터를 전역변수에 저장하는 메서드
  
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('mtdata', ltitle);
    prefs.setStringList('msdata', lscore);
    prefs.setStringList('mtxdata', ltext);
    prefs.setInt('nums', number);
  }
  //사용자가 입력한 데이터를 기기에 저장하는 메서드
}


//맨 위 타이틀 위젯
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '타이틀'),
    );
  }
}

//메인 페이지 위젯
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  List<String> js1 = ['null'];
  List<String> js2 = ['null'];
  List<String> js3 = ['null'];
  int nkk = 0;
  //앱에 사용되는 데이터를 나타내는 변수
  
  _showNextPage(BuildContext context) =>
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NextPage(title: '',)));
  //+버튼을 누를시 생성 페이지로 이동하는 메서드
  
  //평가한 대상의 한줄평과 삭제버튼을 출력하는 메서드
  void _showDialog(int n){
    showDialog(
      context: context,
      builder: (BuildContext){
        return AlertDialog(
          title: new Text(context.watch<SimpleState>().lt[n]),
          content:SingleChildScrollView(child:new Text(context.watch<SimpleState>().ltx[n])),
          actions: <Widget>[
            new FlatButton(
              child: new Text("삭제"), //삭제버튼
              onPressed:(){
                context.read<SimpleState>().deltitle(n);
                context.read<SimpleState>().delscore(n);
                context.read<SimpleState>().deltext(n);
                context.read<SimpleState>().save();
                Navigator.pop(context);
                //해당 항목의 데이터를 삭제하고 저장
              }
            ),
            new FlatButton( //그냥 뒤로가는 취소버튼
                child: new Text("취소"),
                onPressed:(){
                  Navigator.pop(context);
                }
            )
          ]
        );
      }
    );
  }
  
  @override
  void initState() { //기기에 저장된 데이터를 가져오는 생성자
    super.initState();
    _loadCounter();
  }
  
  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    setState(() {
      js1=(prefs.getStringList('mtdata')??['null']);
      js2=(prefs.getStringList('msdata')??['null']);
      js3=(prefs.getStringList('mtxdata')??['null']);
      nkk=(prefs.getInt('nums')??0);
      context.read<SimpleState>().setnbs(nkk);
      context.read<SimpleState>().jsonlist(js1, js2, js3);
    });
  }
  //저장된 데이터를 가져와 전역변수로 저장
  
  @override
  Widget build(BuildContext context) { //메인 페이지
    return Scaffold(
        appBar: AppBar(
            title: Text('별점 매기기')
          //title: Text(widget.title),
        ),

      //별점을 매긴 대상들을 차례대로 출력하는 리스트뷰 위젯
        body: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: context.watch<SimpleState>().numb,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
              height: 70,
              alignment: Alignment.centerLeft,
              child:Row(//이름, 점수, +버튼을 차례대로 배치하는 row 위젯
                  children: <Widget>[
                    SizedBox(child: Text('  '+context.watch<SimpleState>().lt[index+1],
                        style: TextStyle(fontSize: 22, fontFamily: 'ocf', height: 1)),width:150),
                    SizedBox(child: Text('   '+'★'*int.parse(context.watch<SimpleState>().ls[index+1]),
                        style: TextStyle(fontSize: 30, color:Colors.yellow, height: 1)),width:190),
                    Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            icon: Icon(Icons.add_box_rounded),
                            color:Colors.black,
                            iconSize: 30,
                            onPressed: (){_showDialog(index+1);}
                            )
                    )
                  ]
              ),
            );
          }
        ),
      
      //새로운 항목을 생성하는 페이지로 이동하는 +버튼
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNextPage(context),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        )
    );
  }
}




//새로운 항목을 생성하는 페이지
class NextPage extends StatefulWidget {
  const NextPage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  _backToMainPage(BuildContext context) => Navigator.pop(context);
  late String twotitle='-';
  late String twoscore='0';
  late String twotext='-';
  //입력받은 데이터를 잠시 저장할 string 변수
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column( //제목, 별점, 한줄평을 입력방르 textfield를 세로로 배치하는 column 위젯
              children: <Widget>[
                SizedBox(height: 50.0,),
                TextField (
                  onChanged: (onetitle){ setState((){twotitle = onetitle;});},
                  decoration: InputDecoration(
                      labelText: '제목',
                      icon: Icon(Icons.star),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(3)
            ),
          ),
                SizedBox(height: 20.0,),
                TextField (
                  keyboardType: TextInputType.number,
                  onChanged: (onescore){ setState((){ twoscore = onescore;});},
                  decoration: InputDecoration(
                      labelText: '별점',
                      icon: Icon(Icons.star),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(3)
                  ),
                ),
                SizedBox(height: 20.0,),
                TextField (
                  onChanged: (onetext){ setState((){ twotext = onetext;});},
                  decoration: InputDecoration(
                      labelText: '한줄평',
                      icon: Icon(Icons.star),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(3)
                  ),
                ),
                SizedBox(height: 20.0,),
                ElevatedButton(//입력받은 데이터를 저장하는 "완료" 버튼
                  onPressed: () {_backToMainPage(context);
                    print(twotitle+twoscore+twotext);
                  context.read<SimpleState>().settitle(twotitle);
                  context.read<SimpleState>().setscore(twoscore);
                  context.read<SimpleState>().settext(twotext);
                  context.read<SimpleState>().setlist(twotitle, twoscore, twotext);
                  },
                  child: Text("완료"),
                ),
              ]
          ),
      ),
    ),
    );
  }
}



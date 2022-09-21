import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:platform_channel_game/constants/colors.dart';
import 'package:platform_channel_game/constants/styles.dart';
//blablabla
import '../models/creator.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({Key? key}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {

  static const platform = const MethodChannel("game/exchange");

  Creator? creator;
  bool myTurn = true;

  // 0 branco
  // 1 eu
  // 2 inimigo
  List<List<int>> cells = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(700, 1400));

    return Scaffold(
        body: SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: ScreenUtil().setWidth(550),
                    height: ScreenUtil().setHeight(550),
                    color: colorLightBlue,
                  ),
                  Container(
                    width: ScreenUtil().setWidth(150),
                    height: ScreenUtil().setHeight(550),
                    color: colorMediumBlue,
                  )
                ],
              ),
              Container(
                width: ScreenUtil().setWidth(700),
                height: ScreenUtil().setHeight(850),
                color: colorDarkBlue,
              ),
            ],
          ),
          Container(
            height: ScreenUtil().setHeight(1400),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                creator == null
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        buildButton("Criar", true),
                        SizedBox(width: 10),
                        buildButton("Entrar", false)
                      ])
                    : InkWell(
                        child: Text(
                            myTurn ? "Faça sua jogada" : "Aguarde sua vez",
                            style: textStyle36),
                        onLongPress: () {
                          _sendMessage();
                        },
                      ),
                GridView.count(
                  crossAxisCount: 3,
                  padding: EdgeInsets.all(20),
                  shrinkWrap: true,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    getCell(0, 0),
                    getCell(0, 1),
                    getCell(0, 2),
                    getCell(1, 0),
                    getCell(1, 1),
                    getCell(1, 2),
                    getCell(2, 0),
                    getCell(2, 1),
                    getCell(2, 2)
                  ],
                )
              ],
            )),
          )
        ],
      ),
    ));
  }

  Widget buildButton(String label, bool isOwner) => Container(
        width: ScreenUtil().setWidth(300),
        child: ElevatedButton(
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(label, style: textStyle36)),
          onPressed: () {
            createGame(isOwner);
          },
        ),
      );

  Future createGame(bool isOwner) {
    TextEditingController controller = TextEditingController();

    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Qual o nome do jogo?"),
            content: TextField(controller: controller),
            actions: [
              ElevatedButton(
                  child: Text("Jogar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _sendAction("subscribe", {"channel": controller.text});
                    //.then((value))
                    setState(() {
                      creator = Creator(isOwner, controller.text);
                      myTurn = isOwner;
                    });
                  })
            ],
          );
        });
  }

  Future<bool> _sendAction(
      String action, Map<String, dynamic> arguments) async {
        try {
          final result = await platform.invokeMethod(action, arguments);
          if (result) {
            return true;
          }
        } on PlatformException catch(e) {
          return false;
        }
    return true;
  }

  Widget getCell(int x, int y) => InkWell(
        child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.lightBlueAccent,
          child: Center(
              child: Text(
                  cells[x][y] == 0
                      ? ""
                      : cells[x][y] == 1
                          ? "X"
                          : "O",
                  style: textStyle75)),
        ),
        onTap: () async {
          if (myTurn && cells[x][y] == 0) {
            _showSendingAction();
            _sendAction("sendAction",
                {"tap": "${creator!.creator ? "p1" : "p2"}|$x|$y"});
            // .then((value){})
            //Navigator.of(context).pop();
            setState(() {
              myTurn = false;
              cells[x][y] = 1;
            });

            checkWinner();
          }
        },
      );

  void _showSendingAction() {}

  void _sendMessage() async {
    TextEditingController controller = TextEditingController();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Digite sua mensagem"),
              content: TextField(controller: controller),
              actions: [
                ElevatedButton(
                  child: const Text("Enviar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _sendAction("chat", {
                      "message":
                          '${creator!.creator ? "p1" : "p2"}|${controller.text}'
                    });
                  },
                )
              ]);
        });
  }

  void checkWinner() {}
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:xf_speech_plugin/xf_speech_plugin.dart';

void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeakPage()
    );
  }
}




class SpeakPage extends StatefulWidget {
  @override
  _SpeakPageState createState() => _SpeakPageState();
}

class _SpeakPageState extends State<SpeakPage>
    with SingleTickerProviderStateMixin {
  String speakTips = '长按说话';
  String speakResult = '';

  Animation<double> animation;
  AnimationController controller;


  @override
  void initState() {
    super.initState();
    initPlatformState();

    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
  }

  Future<void> initPlatformState() async {
    final voice = XfSpeechPlugin.instance;
    voice.initWithAppId(iosAppID: '6013d3e4', androidAppID: '6013d3e4');
    final param = new XFVoiceParam();
    param.domain = 'iat';
    param.asr_ptt = '1';
    param.asr_audio_path = 'xme.pcm';
    param.result_type = 'plain';
    // param.voice_name = 'vixx';
    param.voice_name = 'xiaoyan';

    voice.setParameter(param.toMap());
  }
  


  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  // 开始录音
  void _speakStart() {
    controller.forward();
    setState(() {
      speakTips = '识别中...';
    });
    speakResult = '';
    final listen = XfSpeechListener(
        onVolumeChanged: (volume) {
          print('$volume');
        },
        onResults: (String result, isLast) {
          if (result.length > 0) {
            setState(() {
              speakResult += result;
              // "你刚才说了" + 
              XfSpeechPlugin.instance.startSpeaking(
                  string: speakResult
              );
            });
          }
        },
        
        onCompleted: (Map<dynamic, dynamic> errInfo, String filePath) {
          setState(() {
            speakResult = errInfo['desc'];
          });
        }
    );
    XfSpeechPlugin.instance.startListening(listener: listen);

  }

  // 停止录音
  void _speakStop() {
    setState(() {
      speakTips = '长按说话';
    });

    controller.reset();
    controller.stop();
    XfSpeechPlugin.instance.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('讯飞语音')
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _topItem,
              _bottomItem,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _topItem {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
          child: Text(
            '你可以这样说',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
        Text(
          '故宫门票\n北京一日游\n迪士尼乐园',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            speakResult,
            style: TextStyle(color: Colors.blue),
          ),
        )
      ],
    );
  }

  Widget get _bottomItem {
    return FractionallySizedBox(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTapDown: (e) {
              _speakStart();
            },
            onTapUp: (e) {
              _speakStop();
            },
            onTapCancel: () {
              _speakStop();
            },
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      speakTips,
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        height: MIC_SIZE,
                        width: MIC_SIZE,
                      ),
                      Center(
                        child: AnimatedMic(
                          animation: animation,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.close,
                size: 30,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

const double MIC_SIZE = 80;

class AnimatedMic extends AnimatedWidget {
  static final _operatyTween = Tween<double>(begin: 1, end: 0.5);
  static final _sizeTween = Tween<double>(begin: MIC_SIZE, end: MIC_SIZE - 20);

  AnimatedMic({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    return Opacity(
      opacity: _operatyTween.evaluate(animation),
      child: Container(
        height: _sizeTween.evaluate(animation),
        width: _sizeTween.evaluate(animation),
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(MIC_SIZE / 2)),
        child: Icon(
          Icons.mic,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

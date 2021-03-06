import 'package:flutter/material.dart';
import 'package:hsa_app/components/public_tool.dart';
import 'package:hsa_app/model/model/all_model.dart';
import 'package:hsa_app/page/live/live_list_page.dart';

class StationListHeader extends StatefulWidget {

  final String weather;
  final List<LiveLink> openLive;
  final String stationName;

  const StationListHeader(this.weather, this.openLive, this.stationName,{Key key}) : super(key: key);

  @override
  _StationListHeaderState createState() => _StationListHeaderState();
}


class _StationListHeaderState extends State<StationListHeader> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
    padding: EdgeInsets.symmetric(horizontal: 10),
    height: 54,
    color: Colors.transparent,
    child: Stack(
      children: <Widget>[
        
        Positioned(
          left: 0,right: 0,bottom: 4,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                
                Text('机组信息',style: TextStyle(color: Colors.white,fontSize: 20)),
                Text('天气:' + widget.weather,style: TextStyle(color: Colors.white,fontSize: 14)),

                // 应产品要求,屏蔽定位按钮
                SizedBox(
                  height: 22,
                  width: 22,
                  // child: Image.asset('images/station/GL_Locationbtn.png'),
                ),

                SizedBox(
                  height: 32,
                  width: 32,
                  child: widget.openLive.length != 0 ? GestureDetector(
                    child: Image.asset('images/station/GL_Video_btn.png'),
                    onTap: (){
                      pushToPage(context, LiveListPage(openLives: widget.openLive,stationName: widget?.stationName ?? ''));
                    },
                  ) :Container(),
                ),
                
              ],
            ),
          ),
        ),

        // 分割线
        Positioned(
            left: 0,right: 0,bottom: 0,
            child: SizedBox(height: 1,child: Container(color: Colors.white38)),
        ),

      ],
    ));
  }
}
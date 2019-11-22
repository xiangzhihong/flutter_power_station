import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:hsa_app/components/shawdow_widget.dart';
import 'package:hsa_app/components/wave_ball.dart';
import 'package:hsa_app/page/home/view/home_banner.dart';
import 'package:hsa_app/page/station/station_page.dart';
import 'package:hsa_app/theme/theme_gradient_background.dart';
import 'package:hsa_app/util/public_tool.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget tabBarHeader() {
    return Center(
      child: TabBar(
        indicator: const BoxDecoration(),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white, 
        labelStyle: TextStyle(color: Colors.white, fontSize: 15.5), 
        unselectedLabelColor: Colors.grey,
        unselectedLabelStyle:TextStyle(color: Colors.grey, fontSize: 15), 
        indicatorColor: Colors.transparent,
        isScrollable: true,
        tabs: <Widget>[
          SizedBox(height: 40, child: Center(child: Text('特别关注'))),
          SizedBox(height: 40, child: Center(child: Text('全部电站'))),
          SizedBox(height: 40, child: Center(child: Text('福建省'))),
          SizedBox(height: 40, child: Center(child: Text('浙江省'))),
          SizedBox(height: 40, child: Center(child: Text('江西省'))),
          SizedBox(height: 40, child: Center(child: Text('广东省'))),
          SizedBox(height: 40, child: Center(child: Text('广西省'))),
        ],
      ),
    );
  }

  Widget tabBarBody() {
    return Expanded(
      child: Container(
        child: TabBarView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              child: stationList(),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: stationList(),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: stationList(),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: stationList(),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: stationList(),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: stationList(),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: stationList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget stationList() {
    return Container(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, int i) => stationTile(),
      ),
    );
  }

  Widget stationTileTop() {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 24,
                width: 24,
                child: CircleAvatar(
                    radius: 12,
                    backgroundImage:
                        AssetImage('images/home/Home_protrait_icon.png')),
              ),
              SizedBox(width: 10),
              Text('登云水电站',style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          SizedBox(
            height: 24,
            width: 24,
            child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('images/home/Home_keep_btn.png'),
            ),
          ),
        ],
      ),
    );
  }


  Widget stationTileBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: 156,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          // 水波球 + 海拔
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              WaveBall(),
              SizedBox(height: 4),
              Text('45.1m',style: TextStyle(color: Colors.white,fontFamily: 'ArialNarrow',fontSize: 16)),
            ],
          ),

          //  在线 + 报警
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              // 在线状态
              Row(
                children: [
                SizedBox(height: 24,width: 24,
                  child: Image.asset('images/home/Home_online_icon.png'),
                ),
                SizedBox(width: 8),
                Text('在线',style: TextStyle(color: Colors.white,fontSize: 15)),
                ]
              ),

              // 间隔
              SizedBox(height: 40),

              // 报警状态
              Row(
                children: [
                Badge(
                  position: BadgePosition.topRight(top: -8,right: -8),
                  badgeColor: Colors.red,
                  badgeContent: Text('1',style: TextStyle(color: Colors.white),),
                  toAnimate: false,
                  child: SizedBox(height: 24,width: 24,
                    child: Image.asset('images/home/Home_Aalarm_icon.png'),
                  ),
                ),
                SizedBox(width: 8),
                Text('报警',style: TextStyle(color: Colors.white,fontSize: 15)),
                ]
              ),

            ],
          )
        ],
      ),
    );
  }

  Widget stationTile() {
    return Container(
      height: 214,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          GestureDetector(
            onTap: (){
              pushToPage(context, StationPage('','',''));
            },
            child: Container(
              child: SizedBox(
                  height: 212,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      stationTileTop(),
                      stationTileBody(),
                    ],
                  )),
            ),
          ),

          // 底部分割线
          SizedBox(height: 1, child: Container(color: Colors.white24)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemeGradientBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 235,
              child: HomeBanner(),
            ),
            SizedBox(height: 1, child: Container(color: Colors.white24)),
            Expanded(
              child: DefaultTabController(
                initialIndex: 0,
                length: 7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    tabBarHeader(),
                    tabBarBody(),
                    TabBarLineShawdow(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

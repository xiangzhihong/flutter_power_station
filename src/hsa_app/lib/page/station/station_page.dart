import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:hsa_app/api/api.dart';
import 'package:hsa_app/config/config.dart';
import 'package:hsa_app/model/station_info.dart';
import 'package:hsa_app/page/live/live_page.dart';
import 'package:hsa_app/page/runtime/runtime_page.dart';
import 'package:hsa_app/page/framework/webview_page.dart';
import 'package:hsa_app/theme/theme_gradient_background.dart';
import 'package:hsa_app/components/public_tool.dart';
import 'package:hsa_app/util/share.dart';
import 'package:native_color/native_color.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class StationPage extends StatefulWidget {

  final String title;
  final String stationId;
 
  StationPage(this.title, this.stationId);
  @override
  _StationPageState createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {

  StationInfo stationInfo = StationInfo();
  int weatherType = 0;
  String weatherString = '晴';
  List<String> openLive = [];

  @override
  void initState() {
    super.initState();
    reqeustStationInfo(widget.stationId);
    
  }

  Widget wetherImageWidget(int type) {
    if( type == 0 ) {
      return Image.asset('images/station/GL_sun_icon.png');
    }
    if( type == 1 ) {
      return Image.asset('images/station/GL_cloudy_icon.png');
    }
    if( type == 2 ) {
      return Image.asset('images/station/GL_rain_icon.png');
    }
    return Image.asset('images/station/GL_sun_icon.png');
  }

  // 彩云天气
  void requestWeatherCaiyun(Geo geo,WeatherTypeResponseCallBack onSucc,HttpFailCallback onFail) {
    API.weatherCaiyun(geo, onSucc, onFail);
  }

  // 请求电站概要
  void reqeustStationInfo(String stationId) {

    API.stationInfo(stationId,(StationInfo station){
      
      if(station == null) return;
      

      // 彩云天气接口
      requestWeatherCaiyun(station.geo,(int type){
        setState(() {
          if(type == 0) {
            this.weatherString = '晴';
          }
          else if(type == 1) {
            this.weatherString = '多云';
          }
          else if(type == 2) {
            this.weatherString = '雨';
          }
          this.weatherType = type;
        });
      },(String msg){
        setState(() {
          this.weatherString = '晴';
          this.weatherType = 0;
        });
      });
      

      setState(() {
        this.stationInfo =  station;
        if(station.openlive!= null) {
          this.openLive = station.openlive;
        }
      });

    },(String msg){
      debugPrint(msg);
    });

  }

  // 计算 水波纹比率
  static double caculateWaveRatio(StationInfo station) {

    var waterMax = station?.water?.max ?? 0.0;
    var waterCurrent = station?.water?.current ?? 0.0;
    if( waterMax == 0 ) return 0.0;
    if( waterCurrent == 0 ) return 0.0; 
    if( waterCurrent > waterMax) return 1;
    var ratio =  waterCurrent / waterMax;
    return ratio;

  }

  // 计算 功率比率
  static double caculatePowerRatio(Devices devices) {

    var powerMax = devices?.power?.max ?? 0.0;
    var powerCurrent = devices?.power?.current ?? 0.0;
    if( powerMax == 0 ) return 0.0;
    if( powerCurrent == 0 ) return 0.0; 
    if( powerCurrent > powerMax) return 1;
    var ratio =  powerCurrent / powerMax;
    return ratio;

  }

  // UI Wave 
  static double caculateUIWave(double waveRatio) {

    if(waveRatio > 1)  {
      waveRatio = 1;
    }
    var wave = 0.75 - (waveRatio / 2);
    return wave;

  }


  // 波浪高度
  Widget waveWidget(StationInfo stationInfo,double width) { 
     // wave 波浪
     var waveRatio = caculateWaveRatio(stationInfo);
     var wave      = caculateUIWave(waveRatio);
      // 波浪效果
     return Center(
       child: WaveWidget(
         waveFrequency: 3.6,
         config: CustomConfig(
           gradients: [[Color.fromRGBO(3,169,244, 1),Color.fromRGBO(3,169,244, 0.3)]],
           durations: [10000],
           heightPercentages: [wave],
           gradientBegin: Alignment.topCenter,
           gradientEnd: Alignment.bottomCenter
           ),
           waveAmplitude: 0,
           backgroundColor: Colors.transparent,
           size: Size(width, double.infinity),
          ),
      );
  }

  // 富文本收益值
  Widget profitWidget(StationInfo stationInfo) { 
    var profit = stationInfo?.profit ?? 0.0;
    return Center(
      child: RichText(
        text: TextSpan(
          children: 
          [
            TextSpan(text:profit.toString(),style: TextStyle(color: Colors.white,fontFamily: 'ArialNarrow',fontSize: 50)),
            TextSpan(text:' 元',style: TextStyle(color: Colors.white,fontSize: 13)),
          ]
        ),
      ),
    );
  }

  // 当前功率 / 总功率组件
  Widget powerWidget(StationInfo stationInfo) {

   var current = stationInfo?.power?.current ?? 0.0;
   var max = stationInfo?.power?.max ?? 0.0;

   return Center(
     child: RichText(
       text: TextSpan(
         children: 
            [
              TextSpan(text:current.toString(),style: TextStyle(color: Colors.white,fontFamily: 'ArialNarrow',fontSize: 25)),
              TextSpan(text:'/',style: TextStyle(color: Colors.white,fontFamily: 'ArialNarrow',fontSize: 18)),
              TextSpan(text:max.toString(),style: TextStyle(color: Colors.white,fontFamily: 'ArialNarrow',fontSize: 18)),
              TextSpan(text:'kW',style: TextStyle(color: Colors.white,fontFamily: 'ArialNarrow',fontSize: 16)),
            ]
          ),
        ),
    );
  }

  // 大水池
  Widget waterPool(StationInfo stationInfo) {
    // var width = MediaQuery.of(context).size.width - 46;
    var width = MediaQuery.of(context).size.width;
    return  Container(
      height: 266,
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          
          // 波浪球
          waveWidget(stationInfo,width),
          // 富文本收益值
          profitWidget(stationInfo),

          // 左侧水库图片
          /*
          Positioned(
            left: 0,bottom: 12,
            child: SizedBox(
              height: 186,
              width: 33,
              child: Image.asset('images/station/GL_Water_Line.png')),
          ),

          // 渐变条左边
           Positioned(
            left: 0,bottom: 0,
            child: SizedBox(
              height: 160,
              width: 23,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(3,169,244, 1),Color.fromRGBO(3,169,244, 0.3)],
                    begin:Alignment.topCenter,
                    end:Alignment.bottomCenter

                  ),
                ),
              )),
          ),

          // 渐变条右边
           Positioned(
            right: 0,bottom: 0,
            child: SizedBox(
              height: 130,
              width: 23,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(3,169,244, 1),Color.fromRGBO(3,169,244, 0.3)],
                    begin:Alignment.topCenter,
                    end:Alignment.bottomCenter

                  ),
                ),
              )),
          ),

          // 水库文本
          Positioned(
            left: 0,bottom: 200,
            child: Text('水库',style: TextStyle(color: Colors.white,fontSize: 13),
            ),
          ),
          
          // 右侧尾水图片
          Positioned(
            right: 0,bottom: 12,
            child: SizedBox(
              height: 186,
              width: 33,
              child: Image.asset('images/station/GL_Water_Line2.png')),
          ),
          

          // 尾水文本
          Positioned(
            right: 0,bottom: 200,
            child: Text('尾水',style: TextStyle(color: Colors.white,fontSize: 13),
            ),
          ),
          */
          
          
          // 当前功率 / 总功率
          Positioned(
            right: 50,bottom: 15,
            child: powerWidget(stationInfo)
          ),

          // 底部分割线
          Positioned(
            left: 0,right: 0,bottom: 0,
            child: SizedBox(height: 2,child: Container(color: Colors.white54,),),
          ),
        ],
      ),
    );
  }

  // 机组信息
  Widget terminalListHeader() {
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
                Text('机组信息',style: TextStyle(color: Colors.white,fontSize: 15)),
                Text('天气:' + weatherString ,style: TextStyle(color: Colors.white,fontSize: 15)),
                SizedBox(
                  height: 22,
                  width: 22,
                  child: Image.asset('images/station/GL_Locationbtn.png'),
                ),

                SizedBox(
                  height: 32,
                  width: 32,
                  child: openLive.length != 0 ? GestureDetector(
                    child: Image.asset('images/station/GL_Video_btn.png'),
                    onLongPress: (){
                      pushToPage(context, LivePage(title: widget.title?? '',openLives: this.openLive));
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
  


  // 机组列表
  Widget terminalList() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: stationInfo?.devices?.length ?? 0,
          itemBuilder: (context, index) => deviceTile(context,index,stationInfo?.devices[index]),
        ),
    );
  }

  // 右上角标
  Widget badgeRight(bool isMaster,bool isOnline,String text) {
    return  isMaster ? Container(
        height: 16,width: 16,
        decoration: BoxDecoration(
          color: HexColor('009EE4'),
          border: Border.all(color: HexColor('009EE4'),width: 1.5),
          borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(text,style: TextStyle(color: Colors.white,fontSize: 12))))
      : Container(
        height: 16,width: 16,
        decoration: BoxDecoration(
          border: Border.all(color: isOnline ? Colors.white : Colors.white60,width: 1.5),
          borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(text,style: TextStyle(color: isOnline ? Colors.white : Colors.white60,fontSize: 12))),
     );
  }

  Widget fanWidget(bool isMaster) {
    return Center(
      child: SizedBox(height: 34,width: 34,
      child: isMaster ? Image.asset('images/station/GL_unit_on_icon.png') 
        : Image.asset('images/station/GL_unit_off_icon.png')
      ),
    );
  }

    // 展示 EventCount
  String buildEventCount(int eventCount) {
    if(eventCount == null) return '';
    if(eventCount == 0) return '';
    if(eventCount > 99) return '99+';
    return eventCount.toString();
  }

  Widget gradientPowerLine(Devices device,bool isOnline) {

      var maxWidth = MediaQuery.of(context).size.width - 20;
      var ratio = caculatePowerRatio(device);
      ratio = (1 - ratio);
      var right = maxWidth * ratio;

      // 渐变条
      return  isOnline ? Positioned(
          left: 0,right: right,bottom: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [HexColor('4778f7'),HexColor('66f7f9')]
              ),
            ),
            height:2,
    )) : Container();
  }

  Widget gradientPowerLineTag(Devices device,bool isOnline) {

      var maxWidth = MediaQuery.of(context).size.width - 20;
      var ratio = caculatePowerRatio(device);
      ratio = (1 - ratio);
      var right = maxWidth * ratio;
      // 渐变条指示器
      return isOnline ? Positioned(
          right: right,bottom: 0,
            child: SizedBox(width: 30,height: 18, child: Image.asset('images/station/GL_BLight.png'),
            ),
      ) : Container();
  }


  Widget deviceTile(BuildContext context,int index,Devices device){
    
    var badgeName = (index + 1).toString();
    var isMaster = device?.isMaster ?? false;
    var isOnline = device?.status == 'online' ? true : false;
    var currentPower = device?.power?.current ?? 0.0;
    var currentPowerStr = currentPower.toString() + 'kW';
    var timeStamp = device?.updateTime ?? '';
    timeStamp += isOnline ? '         ' : ' 离线';
    var maxPower = device?.power?.max ?? 0;
    var maxPowerStr = maxPower.toString();
    var eventCount = device?.eventCount ?? 0;
    var eventStr = buildEventCount(eventCount);
    
    return Container(
      height: 76,
      child: Stack(
        children: <Widget>[
          
          // 内容
          GestureDetector(
            onTap: (){
              pushToPage(context, RuntimePage(device?.name ?? '',device.address));
            },
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    // 堆叠视图
                    SizedBox(height: 50,width: 50,
                      child: Stack(
                        children:[
                        // 水轮机图标
                        fanWidget(isOnline),
                        // 角标
                        Positioned(right: 2,top: 0,
                          child: badgeRight(isMaster,isOnline,badgeName)
                        ),
                        ]
                      ),
                    ),

                    // 文字
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 8),
                        Text(currentPowerStr,style: TextStyle(color: isOnline ? Colors.white : Colors.white60,
                        fontFamily: 'ArialNarrow',fontSize: 20)),
                        SizedBox(height: 4),
                        Text(timeStamp,style: TextStyle(color: Colors.white54,fontFamily: 'ArialNarrow',fontSize: 15)),
                      ],
                    ),

                    // 告警铃
                    eventCount != 0 ? Badge(
                      badgeContent: Center(child: Text(eventStr,style: TextStyle(color: Colors.white,fontSize: 12))),
                      position: BadgePosition.topRight(top: -12,right: -4),
                      badgeColor: Colors.red,toAnimate: false,
                      child:  SizedBox(height: 24,width: 24,child: Image.asset('images/station/GL_Alarm_icon.png')))
                    : SizedBox(height: 24,width: 24),

                    // 当前功率
                    Text(maxPowerStr,style: TextStyle(color: isOnline ? Colors.white : Colors.white60,fontFamily: 'ArialNarrow',fontSize: 28)),
                  ],
                ),
              ),
            ),
          ),

          // 功率 Tag
          gradientPowerLineTag(device,isOnline),
          // 功率 渐进线
          gradientPowerLine(device,isOnline),
          // 分割线
          Positioned(left: 0,right: 0,bottom: 0,child: Container(height:1,color: Colors.white10)),
        ],
      ),
    );
  }

  // 生成历史访问 URL
  void onTapPushToHistory() async {

    var host = AppConfig.getInstance().webHost;
    var pageItemHistory = AppConfig.getInstance().pageBundle.history;
    var urlHistory = host + pageItemHistory.route ?? AppConfig.getInstance().deadLink;
    var auth = await ShareManager.instance.loadToken();

    var deviceIdList = stationInfo.devices.map((device){
      return device?.address ?? '';
    }).toList();
    var terminalsString = deviceIdList.join(',');
    var titleString = stationInfo?.name ?? '';
    var lastUrl =  urlHistory + '?auth=' + auth + '&address=' + terminalsString + '&title=' + Uri.encodeComponent(titleString);
    debugPrint('历史曲线Url:' + lastUrl);
    pushToPage(context, WebViewPage('', lastUrl,noNavBar:true));
  }


  @override
  Widget build(BuildContext context) {
    return ThemeGradientBackground(
      child: Stack(
        children:[
          
          // 天气图片
          wetherImageWidget(weatherType),

          Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(widget.title ?? '',style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal,fontSize: 20)),
            actions: <Widget>[
              GestureDetector(
                onTap: stationInfo.devices == null ? null : (){
                  onTapPushToHistory();
                },
                child: Center(child: Text('历史曲线',style:TextStyle(color: Colors.white,fontSize: 16)))),
              SizedBox(width: 20),
            ],
          ),
          body: Container(
            child: ListView(
              children: <Widget>[
                waterPool(stationInfo),
                terminalListHeader(),
                terminalList(),
              ],
            ),
          ),
        ),
        
        ]
      ),
    );
  }
}

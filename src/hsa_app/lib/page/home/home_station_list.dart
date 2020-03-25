import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:hsa_app/api/api.dart';
import 'package:hsa_app/components/empty_page.dart';
import 'package:hsa_app/components/public_tool.dart';
import 'package:hsa_app/components/smart_refresher_style.dart';
import 'package:hsa_app/components/spinkit_indicator.dart';
import 'package:hsa_app/components/wave_ball.dart';
import 'package:hsa_app/config/app_theme.dart';
import 'package:hsa_app/debug/debug_api.dart';
import 'package:hsa_app/debug/model/all_model.dart';
import 'package:hsa_app/event/app_event.dart';
import 'package:hsa_app/event/event_bird.dart';
import 'package:hsa_app/model/station.dart';
import 'package:hsa_app/page/station/station_tabbar_page.dart';
import 'package:ovprogresshud/progresshud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeStationList extends StatefulWidget {

  final String homeParam;
  final bool isFromSearch;
  final Function onFirstLoadFinish;

  const HomeStationList({Key key, this.homeParam,this.isFromSearch,this.onFirstLoadFinish}) : super(key: key);
  @override
  _HomeStationListState createState() => _HomeStationListState();

}

class _HomeStationListState extends State<HomeStationList> {
  
  int pageRowsMax = 20;
  //List<Stations> stations = [];
  List<StationInfo> stations = [];
  RefreshController refreshController = RefreshController(initialRefresh: false);
  int currentPage = 1;
  // 0 全部电站, 1 关注电站 , 2 省份电站
  int type = 0; 
  String provinceName = '';
  String keyWord = '';
  List<String> favoriteStations ;

  // 是否空视图
  bool isEmpty = false;
  // 是否首次数据加载完毕
  bool isLoadFinsh = false;

  // 按省获取电站列表 加载首页
  void loadFirst(List<String> list) async {
    
    this.currentPage = 1;
    this.isEmpty = false;
    
    DebugAPI.getStationList(onSucc: (msg){
      
      isLoadFinsh = true;
      refreshController.refreshCompleted();
      
      if(mounted) {
        setState(() {
          this.stations = msg.rows;

        });
      }

      if(stations.length == 0) {
        this.isEmpty = true;
      }

      if(widget.onFirstLoadFinish != null) widget.onFirstLoadFinish();
    },onFail: (msg){
      isLoadFinsh = true;
      refreshController.refreshFailed();

      if(widget.onFirstLoadFinish != null) widget.onFirstLoadFinish();
    },
    isIncludeWaterTurbine:true,
    page:currentPage,
    pageSize:pageRowsMax,
    proviceAreaCityNameOfDotSeparated:provinceName,
    arrayOfStationNoOptAny: list,
    );
  }


  // 刷新下一页
  void loadNext(List<String> list) async {

    currentPage++ ;

    DebugAPI.getStationList(onSucc: (msg){
      
      isLoadFinsh = true;
      
      setState(() {
        if(stations == null || stations?.length == 0) {
          refreshController.loadNoData();
        }
        else{
          this.stations.addAll(msg.rows);
          refreshController.loadComplete();
        }
      });

      if(widget.onFirstLoadFinish != null) widget.onFirstLoadFinish();
    },onFail: (msg){
      isLoadFinsh = true;
      refreshController.refreshFailed();

      if(widget.onFirstLoadFinish != null) widget.onFirstLoadFinish();
    },
    isIncludeWaterTurbine:true,
    page:currentPage,
    pageSize:pageRowsMax,
    proviceAreaCityNameOfDotSeparated:provinceName,
    arrayOfStationNoOptAny: list,
    );
  }

  //获取关注列表
  void getFavoriteStations(){
    DebugAPI.getFavoriteStationNos(onSucc :(msg){
      this.favoriteStations = msg;
      
      initPage();
      if(this.widget.isFromSearch == true) {
        EventBird().on(AppEvent.searchKeyWord, (text){
            this.keyWord = text;
            initPage();
        });
      }
    },onFail: (msg){
      
    });
  }

  // 计算类型和省份
  void caculateType(String homeParam) {
    var isProvince = homeParam.endsWith('省');
    var isCentral = homeParam.endsWith('市');
    if(isProvince == true) {
      this.provinceName = homeParam.split('省').first;
      this.type = 2;
    }else if(isCentral == true){
      this.provinceName = homeParam.split('市').first;
      this.type = 2;
    }
    if(homeParam == '全部电站') {
      this.provinceName = '';
      this.type = 0;
    }
    if(homeParam == '特别关注') {
      this.provinceName = '';
      this.type = 1;
    }
  }
  
  @override
  void initState() {
    super.initState();
    getFavoriteStations();
  }

  void initPage() {
    isLoadFinsh = false;
    caculateType(widget.homeParam);
    if(this.type == 1){
      loadFirst(favoriteStations);
    }else{
      loadFirst(null);
    }
  }

  @override
  void dispose() {
    if(this.widget.isFromSearch == true) {
      EventBird().off(AppEvent.searchKeyWord);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(isLoadFinsh == false) return SpinkitIndicator(title: '正在加载',subTitle: '请稍后');
    if(isEmpty == true) return EmptyPage(title: '暂无数据',subTitle: '');
    return stationListView(context);
  }


  // 电站列表
  Widget stationListView(BuildContext context) {
    
    return SmartRefresher(
      header: appRefreshHeader(),
      footer: appRefreshFooter(),
      enablePullDown: true,
      enablePullUp: true,
      onLoading: ()=> type == 1 ? loadNext(this.favoriteStations) : loadNext(null),
      onRefresh: ()=> type == 1 ? loadFirst(this.favoriteStations) : loadFirst(null),
      controller: refreshController,
      child: ListView.builder(
        itemCount: this.stations?.length ?? 0,
        itemBuilder: (BuildContext context, int index) => stationTile(context,index),
      ),
    );
  }

  Widget stationTile(BuildContext context, int index) {

    var station = stations[index];

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
              // pushToPage(context, StationPage(station.name,station.id.toString()));
              // 新版电站滑块
              pushToPage(context,StationTabbarPage(stations: stations,selectIndex: index));
              
            },
            child: Container(
              child: SizedBox(
                  height: 212,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      stationTileTop(station),
                      stationTileBody(station),
                    ],
                ),
              ),
            ),
          ),
          // 底部分割线
          SizedBox(height: 1, child: Container(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget stationTileTop(StationInfo station) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          // 行
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 24,width: 24,
                child: CircleAvatar(
                  radius: 12,
                  backgroundImage:AssetImage('images/about/about_icon.png'),
                ),
              ),
              SizedBox(width: 10),
              Text(station.stationName,style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),

          // 星星
          GestureDetector(
            child: SizedBox(
              height: 24,width: 24,
              child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.transparent,
                  backgroundImage: station.isCurrentAccountFavorite
                  ? AssetImage('images/home/Home_keep_btn.png')
                  : AssetImage('images/home/Home_keep_no_btn.png'),
              ),
            ),
            onTap:() => requestFocus(station),
          ),
        ],
      ),
    );
  }


  // 请求关注
  void requestFocus(StationInfo station) async {
    DebugAPI.setFavorite(stationNo: station.stationNo,isFavorite:!station.isCurrentAccountFavorite,onSucc: (msg,_){
      Progresshud.showSuccessWithStatus(!station.isCurrentAccountFavorite ? '关注成功':'取消成功' );
      setState(() {
        station.isCurrentAccountFavorite = !station.isCurrentAccountFavorite;
      });
    },onFail: (msg){
      Progresshud.showSuccessWithStatus('请检查网络');
      setState(() {
        station.isCurrentAccountFavorite = !station.isCurrentAccountFavorite;
      });
    });


    // API.focusStation(station.isCurrentAccountFavorite.toString(), !station.isCurrentAccountFavorite, (String msg){
    //   final msg = !station.isCurrentAccountFavorite ? '关注成功' : '取消关注成功'; 
    //   Progresshud.showSuccessWithStatus(msg);
    //   setState(() {
    //     station.isCurrentAccountFavorite = !station.isCurrentAccountFavorite;
    //   });
    // }, (String msg){
    //   Progresshud.showSuccessWithStatus('请检查网络');
    //   setState(() {
    //     station.isCurrentAccountFavorite = !station.isCurrentAccountFavorite;
    //   });
    // });
  }


  // 展示 EventCount
  String buildEventCount(int eventCount) {
    if(eventCount == null) return '';
    if(eventCount == 0) return '';
    if(eventCount > 99) return '99+';
    return eventCount.toString();
  }

  Widget stationTileBody(StationInfo station) {
    // 水位标签
    var waterStr = station?.reservoirCurrentWaterStage.toString() ?? '0.0';
    waterStr += 'm';
    // 告警标签
    var eventCount = station?.undisposedAlarmEventCount ?? 0;
    var eventStr = buildEventCount(eventCount);
    // 离线在线状态
    var isOnline = station?.terminalOnLineCount == 0 ? false : true  ;

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
              WaveBall(station:station),
              SizedBox(height: 4),
              Text(waterStr,style: TextStyle(color: Colors.white,fontFamily: AppTheme().numberFontName,fontSize: 16)),
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
                  child: isOnline 
                  ? Image.asset('images/home/Home_online_icon.png')
                  : Image.asset('images/home/Home_offline_icon.png'),
                ),
                SizedBox(width: 8),
                Text(isOnline ? '在线' : '离线',style: TextStyle(color: Colors.white,fontSize: 15)),
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
                  badgeContent: Text(eventStr,style: TextStyle(color: Colors.white,fontSize:12)),
                  toAnimate: false,
                  child: SizedBox(height: 24,width: 24,
                    child: Image.asset('images/home/Home_Aalarm_icon.png'),
                  ),
                  showBadge: eventCount != 0,
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
}

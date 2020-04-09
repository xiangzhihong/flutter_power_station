// 获取实时参数定时任务
import 'dart:async';
import 'package:hsa_app/api/agent/agent.dart';
import 'package:hsa_app/model/model/all_model.dart';


// 供展示的实时有功数据体
class ActivePowerRunTimeData {

  final String address;
  final String date;
  final double power;
  ActivePowerRunTimeData(this.address, this.date, this.power);
  
}

// 实时运行参数页返回 - 实时参数
typedef NearestRunningDataCallBack = void Function(NearestRunningData runtimeData);

// 电站概要页返回 - 当前有功,电站总有功,当日电站总收益
typedef StationInfoDataCallBack = void Function(StationInfo station);

// 持续获取指定终端实时运行数据
class AgentRunTimeDataLoopTimerTasker {
  
   AgentRunTimeDataLoopTimerTasker({this.isBase,this.terminalAddress,this.timerInterval = 5});

   // 周期间隔 单位 s 秒
   final int timerInterval;
   Timer timer;
   final String terminalAddress;
   final bool isBase;


  void start (NearestRunningDataCallBack onGetRuntimeData) {

    runTimeDataOnce(null, onGetRuntimeData);

    timer = Timer.periodic(Duration(seconds: timerInterval), (t) {
      
      runTimeDataOnce(t, onGetRuntimeData);

    });
  }

  // 运行时数据
  void runTimeDataOnce(Timer t, NearestRunningDataCallBack onGetRuntimeData) {
    AgentQueryAPI.remoteMeasuringRunTimeData(terminalAddress, isBase);
    
    AgentQueryAPI.qureryTerminalNearestRunningData(address: terminalAddress, isBase: isBase,onFail: (_){
      t?.cancel();
    },
    onSucc: (data,msg){
      if(onGetRuntimeData != null) onGetRuntimeData(data);
    });
  }
  
  void stop () {
    timer?.cancel();
  }

}


 // 持续获取某个电站下,多个终端运行数据 获取当前有功和电量、预估值, 仅支持在线的终端
class AgentStationInfoDataLoopTimerTasker {
  
   final StationInfo station;
   AgentStationInfoDataLoopTimerTasker(this.station, {this.timerInterval = 5});

   // 周期间隔 单位 s 秒
   final int timerInterval;

   Timer timer;
 
   void start (StationInfoDataCallBack onGetStationInfo) {

   // 总收益
   double _money = 0.0;
   // 当前有功
   List<ActivePowerRunTimeData> datas = [];
   // 总有功
   double _totalActivePower = 0.0;

   // 剩余未返回次数
   int unResponeseAck = 0;

    final terminalAddressList = station.waterTurbines.map((w)=>w.deviceTerminal.terminalAddress).toList();
    final isBaseList = station.waterTurbines.map((w)=>w.deviceTerminal.deviceType.compareTo('S1-Pro') == 0  ? false : true).toList();

    if(terminalAddressList == null)return;
    if(isBaseList == null)return;
    if(terminalAddressList.length == 0)return;
    if(isBaseList.length == 0)return;
    if(terminalAddressList.length != isBaseList.length) return;

    stationInfOnce(_money, _totalActivePower, datas, unResponeseAck, onGetStationInfo);
    
    // 定时读取
    timer = Timer.periodic(Duration(seconds: timerInterval), (t) {

    stationInfOnce(_money, _totalActivePower, datas, unResponeseAck, onGetStationInfo);

    }
    
    );
  }

   void stationInfOnce(double _money, double _totalActivePower, List<ActivePowerRunTimeData> datas, int unResponeseAck, StationInfoDataCallBack onGetStationInfo) {

    var stationResult = station;

    final terminalAddressList = station.waterTurbines.map((w)=>w.deviceTerminal.terminalAddress).toList();
    final isBaseList = station.waterTurbines.map((w)=>w.deviceTerminal.deviceType.compareTo('S1-Pro') == 0  ? false : true).toList();
    final price = ElectricityPrice(
      spikeElectricityPrice: station.spikeElectricityPrice ?? 0.0,
      peakElectricityPrice: station.peakElectricityPrice ?? 0.0,
      flatElectricityPrice: station.flatElectricityPrice ?? 0.0,
      valleyElectricityPrice: station.valleyElectricityPrice ?? 0.0,
    );

     // 初始化
     _money = 0.0;
     _totalActivePower = 0.0;
     datas = [];
     unResponeseAck = terminalAddressList.length;
     
     // 并发召测当前有功和电量、预估值
     for (int i = 0 ; i < terminalAddressList.length ; i++) {
       final terminalAddress = terminalAddressList[i];
       final isBase = isBaseList[i];
       AgentQueryAPI.remoteMeasuringElectricParam(terminalAddress, isBase);
     }
     
     for (int j = 0; j < terminalAddressList.length; j++) {
     
         final terminalAddress = terminalAddressList[j];
         final isBase = isBaseList[j];
     
         AgentQueryAPI.qureryTerminalNearestRunningData(address: terminalAddress, isBase: isBase,price: price,onSucc: (data,msg){
     
           unResponeseAck -- ;
     
           final active = data.power;
           final date = data.dataCachedTime != ''  ?  data.dataCachedTime ?? '0000-00-00 00:00:00' : '0000-00-00 00:00:00';
           final activeData =  ActivePowerRunTimeData(terminalAddress, date, active);
           datas.add(activeData);
     
           _totalActivePower += active;
           _money += data.money;
           
           if(unResponeseAck <= 0) {
     
             // 按输入顺序排序
             datas = sort(datas, terminalAddressList); 

             // 拼接到输出 stationResult
             for (int k = 0 ; k < datas.length ; k++) {
               final turbine = stationResult.waterTurbines[k];
               final data = datas[k];
               turbine?.deviceTerminal?.nearestRunningData?.dataCachedTime = data?.date ?? '0000-00-00 00:00:00';
               turbine?.deviceTerminal?.nearestRunningData?.power = data?.power ?? 0.0;
             }
             stationResult.totalMoney = _money;
             stationResult.totalActivePower = _totalActivePower;

             if(onGetStationInfo != null) onGetStationInfo(stationResult);
           }
         },onFail: (msg){
     
           unResponeseAck --;
     
           final activeData =  ActivePowerRunTimeData(terminalAddress, '0000-00-00 00:00:00', 0.0);
           datas.add(activeData);
     
           if(unResponeseAck <= 0) {
     
             // 按输入顺序排序
             datas = sort(datas, terminalAddressList); 

             // 拼接到输出 stationResult
             for (int k = 0 ; k < datas.length ; k++) {
               final turbine = stationResult.waterTurbines[k];
               final data = datas[k];
               turbine?.deviceTerminal?.nearestRunningData?.dataCachedTime = data?.date ?? '0000-00-00 00:00:00';
               turbine?.deviceTerminal?.nearestRunningData?.power = data?.power ?? 0.0;
             }
             stationResult.totalMoney = _money;
             stationResult.totalActivePower = _totalActivePower;
             if(onGetStationInfo != null) onGetStationInfo(stationResult);
     
           }
         });
      }
   }


  // 多线程打乱了顺序,按输入顺序排序
  List<ActivePowerRunTimeData> sort(List<ActivePowerRunTimeData> oldDatas,List<String> terminalAddressList) {
    
    List<ActivePowerRunTimeData> result = [];

    for (int i = 0; i < terminalAddressList.length; i++) {
      final addr = terminalAddressList[i];
      for (int j = 0 ; j < oldDatas.length ; j++) {
        final item = oldDatas[j];
        if(item.address.compareTo(addr) == 0) {
          result.add(item);
          break;
        }
      }
    } 
    return result;
  }
  
  void stop () {
    timer?.cancel();
  }
 

}
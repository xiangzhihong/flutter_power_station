import 'package:hsa_app/api/api.dart';
import 'package:hsa_app/api/api_helper.dart';
import 'package:hsa_app/model/response/all_resp.dart';

class APIUpdate{

  //获取升级文件的类型
  static void upgradeFileType({UpgradeFileTypeCallback onSucc,HttpFailCallback onFail}) async {
    
    final path = API.baseHost + '/v1/DeviceTerminalOtaFileManage/GetUpgradeFileType';
    
    HttpHelper.httpGET(path, null, (map,_){

      var list = UpdateFileTypeResp.fromJson(map);
      if(onSucc != null) onSucc(list.data);
      
    }, onFail);
  }

  //获取升级文件列表
  static void upgradeFileList({String deviceType, String deviceVersion, String upgradeFileType,
      UpgradeFileListCallback onSucc,HttpFailCallback onFail}) async {

    Map<String, dynamic> param = new Map<String, dynamic>();

    //设备类型
    if(deviceType != null){
      param['deviceType'] = deviceType;
    }
    
    //设备版本
    if(deviceVersion != null){
      param['deviceVersion'] = deviceVersion;
    }

    //文件类型
    if(upgradeFileType != null){
      param['upgradeFileType'] = upgradeFileType;
    }  
    
    final path = API.baseHost + '/v1/DeviceTerminalOtaFileManage/GetUpgradeFileInfo';
    
    HttpHelper.httpGET(path, param, (map,_){

      var list = UpdateFileResp.fromJson(map);
      if(onSucc != null) onSucc(list.data);
      
    }, onFail);
  }

  //获取升级任务列表
  static void upgradeTaskList({String stationNo, String terminalAddress, List<String> upgradeTaskStates,
      int page,int pageSize,String startDateTime,String endDateTime,
      UpgradeTaskListCallback onSucc,HttpFailCallback onFail}) async {

    Map<String, dynamic> param = new Map<String, dynamic>();

    //终端地址
    if(terminalAddress != null){
      param['terminalAddress'] = terminalAddress;
    }
    
    //任务状态
    if(upgradeTaskStates != null){
      param['upgradeTaskStates'] = upgradeTaskStates;
    }

    //起始时间
    if(startDateTime != null){
      param['startDateTime'] = startDateTime;
    }  
    //结束时间
    if(endDateTime != null){
      param['endDateTime'] = endDateTime;
    } 

    param['page'] = (page != null ? page : 1 );
    param['pageSize'] = (pageSize != null ? pageSize : 20 );

    
    var path = API.baseHost + '/v1/DeviceTerminalOtaFileManage/GetUpgradeMissionState' ;

    if(stationNo != null){
      path = path + '/' + stationNo;
    }
    
    HttpHelper.httpGET(path, param, (map,_){

      var list = UpdateTaskResp.fromJson(map);
      if(onSucc != null) onSucc(list.data.updateTaskList);
      
    }, onFail);
  }
}
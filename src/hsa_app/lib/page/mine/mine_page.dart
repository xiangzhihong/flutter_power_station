import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hsa_app/config/config.dart';
import 'package:hsa_app/page/login/login_page.dart';
import 'package:hsa_app/page/setting/modifypswd_page.dart';
import 'package:hsa_app/page/framework/webview_page.dart';
import 'package:hsa_app/theme/theme_gradient_background.dart';
import 'package:hsa_app/util/public_tool.dart';
import 'package:hsa_app/util/share.dart';
import 'package:native_color/native_color.dart';
import 'package:url_launcher/url_launcher.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {

  String userName = '';

  @override
  void initState() {
    super.initState();
    updateUserName();
  }

  // 我的页面头部
  Widget avatorView() {
    return Container(
      height: 198,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 圆环
            SizedBox(
              height: 100,
              width: 100,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/mine/My_protarit_icon.png'),
              ),
            ),
            SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(userName, style: TextStyle(color: Colors.white, fontSize: 21)),
                SizedBox(height: 4),
                Text('100座智能电站', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateUserName() async {
    userName = await ShareManager.instance.loadUserName();
    setState(() {
      
    });
  }

  // 修改密码
  void onTapChangePswd(BuildContext context) {
    pushToPage(context, ModifyPswdPage());
  }

  // 关于
  void onTapAbout(BuildContext context) {
    var host = AppConfig.getInstance().webHost;
    var pageItem = AppConfig.getInstance().pageBundle.about;
    var url = host + pageItem.route ?? AppConfig.getInstance().deadLink;
    var title = pageItem.title ?? '';
    pushToPage(context, WebViewPage(title, url));
  }


  // SOS拨号器
  void onTapSOSCall(BuildContext context) {
    onTapSoScall('18046053193');
  }

  Widget loginOutButton() {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
          splashColor: Colors.white,color: HexColor('6699ff'),
          child: Text('退出登录', style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () {
              showAlertViewDouble(context, '提示', '是否退出登录', () {
      // ShareManager().clearAll();
      var route = CupertinoPageRoute(
        builder: (_) => LoginPage(),
      );
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(route, (route) => route == null);
    });
          },
        ),
    );
  }

  Widget itemTile(String title, String iconName, Function onTap) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
              color: Colors.transparent,
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    SizedBox(
                    height: 22,
                    width: 22,
                    child: Image.asset(iconName),
                    ),
                    SizedBox(width: 12),
                    Text(title,style: TextStyle(color: Colors.white,fontSize: 16),)
                    ],
                  ),
                  SizedBox(
                    height: 22,
                    width: 22,
                    child: Image.asset('images/mine/My_next_btn.png'),
                  ),
                ],
              ),
              // leading: Icon(icon, size: 20),
              // title: Text(title),
              // onTap: onTap,
              // trailing: Icon(Icons.navigate_next, size: 20),
            ),
              // 分割线
              SizedBox(height: 0.3,child: Container(color:Colors.white24)),
            ]
          ),
        ),
      ),
    );
  }

  // 界面构建
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemeGradientBackground(
        child: Stack(
          children: [ 
          ListView(
          primary: false,
          children: <Widget>[
            avatorView(),
            itemTile('修改密码', 'images/mine/My_Change_pwd_icon.png', () => onTapChangePswd(context)),
            itemTile('关于智能电站', 'images/mine/My_about_icon.png', () =>  onTapAbout(context)),
            itemTile('SOS', 'images/mine/My_sos_icon.png', () =>  onTapSOSCall(context)),
            // 分割线
          SizedBox(height: 0.3,child: Container(color:Colors.white24)),
            ],
          ),
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 50),child: loginOutButton())),
          ]
        ),
      ),
    );
  }

  // 拨打电话
  Future<bool> onTapSoScall(String phone) async {
    var url = 'tel:';
    if (TargetPlatform.iOS == defaultTargetPlatform) {
      url += '+86' + phone;
    } else if (TargetPlatform.android == defaultTargetPlatform) {
      url += phone;
    }
    var canTouch = await canLaunch(url);
    if (canTouch) {
      bool isOk = await launch(url);
      return isOk;
    }
    showToast('拨打电话失败');
    return false;
  }
}
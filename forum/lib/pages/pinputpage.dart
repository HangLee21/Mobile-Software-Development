import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/pages/settings.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'login.dart';

class PinputPage extends StatelessWidget{
  final String email;
  final String type;
  final String username;
  final String userId;
  final String password1;
  final String password2;
  const PinputPage(this.username, this.userId, this.password1, this.password2,{super.key,required this.email,required this.type});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('验证码'),
      ),
      body: FractionallySizedBox(
        widthFactor: 1,
        child: PinputExample(type,username, userId,password1,password2 , email: email,),
      ),
    );
  }
}

/// This is the basic usage of Pinput
/// For more examples check out the demo directory
class PinputExample extends StatefulWidget {
  final String email;
  final String type;
  final String username;
  final String userId;
  final String password1;
  final String password2;
  const PinputExample(this.type, this.username,this.userId,this.password1,this.password2, {Key? key,required this.email}) : super(key: key);

  @override
  State<PinputExample> createState() => _PinputExampleState();
}

class _PinputExampleState extends State<PinputExample> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool bingo = false;
  
  @override
  void initState(){
    super.initState();
    sendCode();
    
  }
  
  void sendCode()async{
    requestPost('/api/user/send_code', {}, {},query: {
      'email': widget.email
    }).then((http.Response res){
      if(res.statusCode != 200){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('验证码发送失败')));
      }
    });
  }

  void complete(String pin)async{
    requestGet('/api/user/verify_code', {}, query: {
      'email': widget.email,
      'code': pin,
    }).then((http.Response res) {
      if (res.statusCode == 200) {
        print('type:${widget.type}');
        if(widget.type == 'signup') {
          requestPost('/api/user/register',{
            'userId': widget.userId,
            'userAvatar': 'https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png',
            'userEmail': widget.email,
            'userPassword': widget.password1,
            'userName': widget.username
          },{}).then((http.Response res2){
            if(res2.statusCode == 200){
              setState(() {
                bingo = true;
              });
              EasyLoading.showSuccess('注册成功');
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginLayout()),(route) => false);
            }else{
              EasyLoading.showError('注册失败');
            }
          });
        }else if(widget.type == 'changepassword'){
          requestPost('/api/account/change_password',{
            'userId': LocalStorage.getString('userId'),
            'oldPassword': widget.password1,
            'newPassword': widget.password2
          },{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${LocalStorage.getString('token')}'
          }).then((http.Response res2){
            if(res2.statusCode == 200){
              EasyLoading.showSuccess('修改成功');

            }else{
              EasyLoading.showSuccess('修改失败');
            }
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => Settings()));
          });
        }
      } else {
        bingo = false;
      }
      pinController.text = pinController.text;
    });


  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    /// Optionally you can use form to validate the Pinput
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('输入验证码',style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),),
          const SizedBox(height: 30,),
          const Text('验证码已发送至邮箱：'),
          Text(widget.email),
          const SizedBox(height: 30,),
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: pinController,
              focusNode: focusNode,
              androidSmsAutofillMethod:
              AndroidSmsAutofillMethod.smsUserConsentApi,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              separatorBuilder: (index) => const SizedBox(width: 8),
              validator: (value) {
                valid()async{
                  await Future.delayed(Duration(milliseconds: 10));
                  return bingo?null:'验证码错误';
                }
                valid().then((str){
                  return str;
                });

              },
              // onClipboardFound: (value) {
              //   debugPrint('onClipboardFound: $value');
              //   pinController.setText(value);
              // },
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) {
                debugPrint('onCompleted: $pin');
                complete(pin);
              },
              onChanged: (value) {
                debugPrint('onChanged: $value');
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: focusedBorderColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: Colors.redAccent),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              sendCode();
            },
            child: const Text('Resend'),
          ),
        ],
      ),
    );
  }
}
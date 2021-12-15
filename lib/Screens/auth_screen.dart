import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/model/http_exception.dart';
import 'package:shop/provider/auth.dart';

class AuthScreen extends StatelessWidget {
  static const String routeName='auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize=MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 0.5),
                  Color.fromRGBO(255, 188, 117, 0.9),

                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                stops: [0,1]
              )
            ),
          ),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(10),
              height:deviceSize.height ,
              width:deviceSize.width ,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(

                      child: Container(

                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.symmetric(vertical: 8,horizontal: 60),
                    child: Text('My Shop ',style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.deepOrange,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0,2)
                        )
                      ]
                    ),
                  )),


                  Spacer(),
                  Flexible(child: AuthCard(),flex:deviceSize.width>600?2:1,),
                ],
              ),
            ),
          )
        ],
        
      ),
    );
  }
}
class AuthCard extends StatefulWidget {

  @override
  State<AuthCard> createState() => _AuthCardState();

}
enum AuthMode{
  Login,SignUp
}

class _AuthCardState extends State<AuthCard>with SingleTickerProviderStateMixin {
  final GlobalKey<FormState>formKey=GlobalKey();
  AuthMode authMode=AuthMode.Login;
  Map<String?,String?>authData={
    'email':'',
    'password':'',
  };
  var isLodaing=false;
  final passwordController=TextEditingController();
   late AnimationController Controller;
  late Animation<Offset>slideAnimation;
  late Animation<double>OpicityAnimation;

  @override
  void initState() {
    super.initState();
      Controller=AnimationController(vsync:this,duration:Duration(microseconds: 300));
      slideAnimation=Tween<Offset>(begin:Offset(0,-0.15),
          end: Offset(0,0)).animate(CurvedAnimation(parent: Controller, curve: Curves.easeIn,
      ));
      OpicityAnimation=Tween<double>(begin:0.0,
          end: 1.0).animate(CurvedAnimation(parent: Controller, curve: Curves.easeIn,
      ));
    }
    @override
  void dispose() {
    super.dispose();
    Controller.dispose();
  }
  Future<void>submit()async{
    if(!formKey.currentState!.validate()){
      return;
    }
    formKey.currentState!.save();
    setState(() {
      isLodaing=true;
    });
    try{
      if(authMode==AuthMode.Login){
        await Provider.of<Auth>(context,listen: false).login(authData['email']!
        , authData['password']!);
      }else{
        await Provider.of<Auth>(context,listen: false).signup(authData['email']!
        , authData['password']!);
      }

    }on httpExcptions catch(error){
      var errorMessage='Authentaction Failed';
      if (error.toString().contains('EMAIL_EXIST')){
        errorMessage='the email address is already in use';
      }else if(error.toString().contains('INVALID_EMAIL')){
        errorMessage='this is not a valid email';
      }else if(error.toString().contains('WEAK_PASSWORD')){
        errorMessage='weak password';
      }else if(error.toString().contains('EMAIL_NOT_FOUND')){
        errorMessage='could not found this email';
      }else if(error.toString().contains('INVALID_PASSWORD')){
        errorMessage='invalid Password';
      }
      showErrorMessageDialog(errorMessage);

    }
    catch(error){
      String errorMessage=error.toString();
      showErrorMessageDialog(errorMessage);

    }
    setState(() {
      isLodaing=false;
    });
  }
  void switchAuthMood(){
    if(authMode==AuthMode.Login){
      setState(() {
        authMode=AuthMode.SignUp;
      });
      Controller.forward();
    }else{
      setState(() {
        authMode=AuthMode.Login;
      });
      Controller.reverse();
    }
  }
  @override

  Widget build(BuildContext context) {
    final deviceSize=MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),

      ),
      child: AnimatedContainer(
        duration: Duration(microseconds: 300),
        curve: Curves.easeIn,
        height: authMode==AuthMode.SignUp?320:260,
        constraints: BoxConstraints(minHeight: authMode==AuthMode.SignUp?320:260),
        width: deviceSize.width*0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'E-mail'
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val){
                    if(val!.isEmpty||!val.contains('@')){
                      return'Invalid Email';
                    }return null;
                  },
                  onSaved: (val){
                    authData['email']=val!;

                  },
                ),   TextFormField(
                  obscureText: true,
                  controller: passwordController
                  ,
                  decoration: InputDecoration(

                    labelText: 'password'
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val){
                    if(val!.isEmpty||val.length<=5){
                      return'password is too Short';
                    }return null;
                  },
                  onSaved: (val){
                    authData['password']=val!;

                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: authMode==AuthMode.SignUp?60:0,
                    maxHeight: authMode==AuthMode.SignUp?120:0
                  ),
                  duration: Duration(milliseconds: 300),
                  child: FadeTransition(
                    opacity: OpicityAnimation,
                    child: SlideTransition(position: slideAnimation,
                      child:   TextFormField(
                        obscureText: true,
                        enabled: authMode==AuthMode.SignUp,
                        decoration: InputDecoration(
                            labelText: 'Confirm Password'
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: authMode==AuthMode.SignUp?(val){
                          if(val!=passwordController.text){
                            return'passwoed is not match';
                          }return null;
                        }:null,

                      ),

                    ),
                  ),

                ),
                SizedBox(height: 20,),
                if(isLodaing)CircularProgressIndicator(),
                 ElevatedButton(child:Text('supmit'),onPressed: (){
                   submit();

                 },style:  ButtonStyle(
                   backgroundColor: MaterialStateProperty.all<Color>(
                     Colors.purple
                   ),
                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                 RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.red)
    )
    )
    ),
                   ),
                 TextButton(onPressed: (){
                   switchAuthMood();
                 }, child: Text('${authMode==AuthMode.Login?'SignUp':'login'} INSTED'))

              ],
            ),
          ),),
      ),
    );
  }

  void showErrorMessageDialog(String errorMessage) {
    showDialog(context: context, builder: (buildContext){
      return AlertDialog(
        title: Text('An error occurred'),
        content: Text(errorMessage),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text('OK'))
        ],
      );
    });


  }

}



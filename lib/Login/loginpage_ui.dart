import 'package:flutter/material.dart';
import 'package:social_app/Login/loginpage_model.dart';
import 'package:social_app/navigation_bar.dart';

class LoginPageUI extends StatefulWidget {
  final LoginPageModel model = LoginPageModel();
  final Function() onTap;
  LoginPageUI({super.key, required this.onTap});

  @override
  State<LoginPageUI> createState() => _LoginPageUIState();
}

class _LoginPageUIState extends State<LoginPageUI> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.grey.shade900,
                  Colors.grey.shade700,
                  Colors.grey.shade500,
                ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80,),
            const Padding(
              padding: EdgeInsets.only(left: 18),
              child: Text('Login',style: TextStyle(fontSize: 50,
                color: Colors.white70,),),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 18),
              child: Text('Welcome! Back',
                style: TextStyle(fontSize: 18,
                  color: Colors.white),),
            ),
            const SizedBox(height: 60,),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60),
                      topRight: Radius.circular(60)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80,),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 18),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 4,color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [BoxShadow(
                                  color: Colors.grey,offset: Offset(0, 10),
                                  blurRadius: 10
                              )]
                          ),
                          child: Column(
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                    hintText: 'Enter your email',
                                    border: InputBorder.none
                                ),
                                controller: _emailController,
                              ),
                              const SizedBox(height: 2,),
                              TextField(
                                decoration: const InputDecoration(
                                    hintText: 'Enter your password',
                                    border: InputBorder.none
                                ),
                                controller: _passwordController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Not A Member',style: TextStyle(color: Colors.grey.shade500),),
                            TextButton(onPressed:widget.onTap,
                                child: const Text('Register',style: TextStyle(fontWeight: FontWeight.bold,
                                color: Colors.blue),))
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextButton(onPressed: (){
                            widget.model.signIn(_emailController.text,_passwordController.text);
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const CustomNavigationBar()));
                          },
                            child: const Text('Login',style: TextStyle(color: Colors.white,
                                fontSize: 18, fontWeight: FontWeight.bold),),),
                        ),
                        const SizedBox(height: 40,),
                        Text('or continue with ',style: TextStyle(color: Colors.grey.shade500),),
                        OutlinedButton(
                          onPressed: (){},
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0), // Border radius
                                ),
                              ),
                              side: MaterialStateProperty.all(BorderSide(color: Colors.grey.shade900,width: 1),),
                              foregroundColor: MaterialStateProperty.all(Colors.grey.shade900)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/telephone.png',width: 20,height: 20,),
                                const SizedBox(width: 5,),
                                const Text('Phone',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        OutlinedButton(
                          onPressed: (){
                            widget.model.signInWithGoogle();
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0), // Border radius
                                ),
                              ),
                              side: MaterialStateProperty.all(BorderSide(color: Colors.grey.shade900,width: 1),),
                              foregroundColor: MaterialStateProperty.all(Colors.grey.shade900)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/google.png',width: 20,height: 20,),
                                const SizedBox(width: 5,),
                                const Text('Google',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pratice_flutter/common/common_widget.dart';
import 'package:pratice_flutter/viewmodels/internetcheck_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'data_view.dart';

class LoginView extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Consumer<AuthViewModel>(
              builder: (context,authViewModel,child){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                    ),
                    Row(
                      children: [
                        Icon(Icons.phone),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              errorText: authViewModel.isUserName == false && authViewModel.isLoginClick ==true? "Enter User Name":null,
                              hintText: 'Username (or) Phone number/Email',

                            ),
                            onChanged: (value){
                             if(value.isNotEmpty){
                               authViewModel.enterUserName(value);
                             }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      children: [
                        const Icon(Icons.star),
                        const SizedBox(width: 8,),
                        Expanded(child: TextField(
                          controller: _passwordController,
                          decoration:  InputDecoration(
                            errorText: authViewModel.isPassword == false && authViewModel.isLoginClick==true ? "Enter Password":null,

                            hintText: 'Password',

                          ),
                          onChanged: (value){
                            if(value.isNotEmpty){
                              authViewModel.enterPassword(value);
                            }
                          },
                          obscureText: true,
                        ),)
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(value: authViewModel.isCheck, onChanged: (bool? value)async {
                          await authViewModel.clickCheckBox(value);

                        }),
                        const Text(
                          'Terms & Conditions',
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<ConnectivityViewModel>(
                      builder: (context, connectivityViewModel, child) {
                        return ElevatedButton(
                          onPressed: () async {
                            authViewModel.clickLoginButton(true);
                            if(authViewModel.isCheck==true){
                              if(connectivityViewModel.isConnected){
                                if(_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty){
                                  await authViewModel.login(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                }else{
                                  authViewModel.enterUserName('');
                                  authViewModel.enterPassword('');
                                }
                              }else{
                                CommonWidget.showToast('No Internet Connection');
                              }
                            }else {
                              CommonWidget.showToast("Please check Terms & Conditions");

                            }
                            if (authViewModel.user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => DataViewScreen()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: Size(double.infinity, 50), // Make button full width
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: authViewModel.isLoginDataCall ==true ? Center(child: CircularProgressIndicator(),):const Text('Login'),
                        );
                      },
                    ),

                  ],
                );
              },
            )
          )
        ),
      )
    );
  }
}

import 'package:admin_panel/provider/admin_login_provider/admin_login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AdminLoginScreen extends StatefulWidget {
  static String routeName = "/admin_login_screen";

  const AdminLoginScreen({super.key});
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscure = true;
  final bool _rememberMe = false;
  InputBorder? inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(color: Colors.green));

  @override
  Widget build(BuildContext context) {
    AdminLoginProvider adminLoginProvider = Provider.of<AdminLoginProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: constraints.maxWidth * 0.4,
              height: constraints.maxHeight * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      /*image: DecorationImage(
                        image: AssetImage('assets/image/colorkit.png'),
                        fit: BoxFit.cover,
                      ),*/
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: AutofillGroup(
                      child: Column(
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SelectableText(
                            "Login as Admin",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 50,),
                          TextFormField(
                            controller: emailController,
                            autofillHints: [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: inputBorder,
                              enabledBorder: inputBorder,
                              focusedBorder: inputBorder,
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Email",
                              hintStyle: TextStyle(
                                  fontSize: 16),
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          Column(
                            children: [
                              TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure,
                                autofillHints: [AutofillHints.password],
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  border: inputBorder,
                                  enabledBorder: inputBorder,
                                  focusedBorder: inputBorder,
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "Password",
                                  hintStyle: TextStyle(fontSize: 16),
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure =
                                        !_isObscure;
                                      });
                                    },
                                  ),
                                ),
                                onFieldSubmitted: (value) async {
                                  Map<String, dynamic> body = {
                                    "email": emailController.text.trim(),
                                    "password": passwordController.text.trim(),
                                  };

                                  await adminLoginProvider.adminLogin(body);
                                },
                              ),
                              SizedBox(height: 5,),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    // Get.to(const ForgotPasswordScreen());
                                  });
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Forgot Password?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     Checkbox(
                          //       value: _rememberMe,
                          //       onChanged: (bool? newValue) {
                          //         setState(() {
                          //           _rememberMe = newValue!;
                          //         });
                          //       },
                          //       activeColor: Colors.green, // Checkbox color
                          //     ),
                          //     const Text(
                          //       "Remember Me",
                          //       style: TextStyle(fontSize: 16, color: Colors.black),
                          //     ),
                          //   ],
                          // ),
                         // SizedBox(height: 70,),
                          ElevatedButton(
                            onPressed: adminLoginProvider.isLoading?null: () async {
                              Map<String, dynamic> body = {
                                "email": emailController.text.trim(),
                                "password": passwordController.text.trim(),
                              };

                              await adminLoginProvider.adminLogin(body);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(7),
                                  side: BorderSide(color: Colors.green)
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child:adminLoginProvider.isLoading?
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            )
                                : Text(
                              "Login",
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.w500, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
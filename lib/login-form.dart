import 'package:flutter/material.dart';
import 'package:attendancesystem/scanner-page.dart';
import 'package:attendancesystem/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  static late Function resetScript;

  LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController oTPController = TextEditingController();

  late Map<String, dynamic> otpResponse;
  String otpStatus = '';

  bool _obscureText = true;
  String otpResult = '';
  String status = '';
  late Map<String, dynamic> decodedResult;

  var headers = {
    "Content-Type": "application/json",
    "Authorization":
        "Bearer eyJUWVAiOiJKV1QiLCJBTEciOiJIUzI1NiJ9.eyJSRUNPUkQiOiJleUpWYzJWeWMxOUJZMk52.STZJbEp2ZDJWdVlTQlRZV2QxYVc0aUxDSl",
    "API-Key":
        "JMCS8280C000HaS9448da4501hBaa62295b187HaS4a060cfd05hjM47fcc96a38HaS9448da45",
    "Identity":
        "477466316933354762314336524167685337385278304B664A624C6A5250507A6331556C50723047675F4D"
  };

  @override
  void initState() {
    super.initState();
    LoginPage.resetScript = resetScript;
  }

  void resetScript() {
    setState(() {
      otpResult = '';
    });
  }

  void toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void fetchAccount(String username, String password) async {
    var data = {"student_id": username, "password": password};
    var url =
        Uri.http('119.92.169.229', '/SSAAM/API-Services/UserAccount/Shakehand');

    try {
      setState(() {
        status = "Connecting...";
      });

      var response =
          await http.post(url, headers: headers, body: jsonEncode(data));

      setState(() {
        status = "Retrieving Data...";
      });

      if (response.statusCode.toString() == "200") {
        decodedResult = json.decode(response.body);
        otpResult = decodedResult['Result'];
        otpStatus = decodedResult['Status'];

        setState(() {
          status = "Success";

          print("Website entered");
        });
      } else {
        setState(() {
          status = 'Error: ' + response.statusCode.toString();

          print("Website exited");
        });
      }
    } catch (error) {
      status = 'Error: ' + error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 03, 46, 89),
        title: const Text("Attendance System"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 40.0,
            ),
            Image.asset(
              'assets/Logo.jpg',
              fit: BoxFit.cover,
              width: 200.0,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                  labelText: 'Username', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: GestureDetector(
                    onTap: toggleObscureText,
                    child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.blue[800],
                    ),
                  )),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Visibility(
              visible: otpResult.contains('OTP Sent!') ? true : false,
              child: TextField(
                controller: oTPController,
                decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    border: const OutlineInputBorder(),
                    suffixIcon: TextButton(
                        child: const Text('Verify'),
                        onPressed: () async {
                          String username = usernameController.text;
                          String password = passwordController.text;
                          print(usernameController.text.toString());
                          var data = {
                            "student_id": username,
                            "password": password,
                            "otp": oTPController.text
                          };
                          var url = Uri.http('119.92.169.229',
                              '/SSAAM/API-Services/UserAccount/login');
                          var response = await http.post(url,
                              body: jsonEncode(data), headers: headers);

                          if (response.statusCode.toString() == "200") {
                            otpResponse = json.decode(response.body);
                            print(otpResponse.toString());
                            if (otpResponse['Result'] == 'LOGIN SUCCESS') {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const Home()));
                            }
                          } else {
                            print('ERROR!!');
                          }
                        })),
              ),
            ),
            const SizedBox(height: 20.0),
            Column(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF43A047))),
                  onPressed: () async {
                    if (status != "" && !status.contains("Error:")) {
                      SnackBar snackBar = const SnackBar(
                        content: Text(
                          "Please wait for a little bit, attempting to connect...",
                          style: TextStyle(color: Colors.red),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }

                    fetchAccount(
                        usernameController.text, passwordController.text);

                    Future.delayed(const Duration(seconds: 40), () {
                      setState(() {
                        otpStatus = '';
                      });
                    });
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                status != "" && status != 'Success'
                    ? Text(
                        status,
                        style: const TextStyle(
                            fontSize: 18, color: Color.fromRGBO(0, 0, 0, 1)),
                      )
                    : Container(),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),

            //Dili gyud unta Apil para lng sulay sa Scanner kay wala pa ma Completo ang 2FA
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const QRViewExample()));
                },
                child: const Text('Scan')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              child: const Text("Home"),
            ),
          ],
        ),
      ),
    );
  }
}

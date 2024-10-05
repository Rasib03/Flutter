import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'Sentiment Analyzer',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController _controller;
  String sentiment = "";
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: Text(
          widget.title,
          style:
              GoogleFonts.playfair(color: Colors.grey.shade800, fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * .3),
              child: Center(
                child: Text(
                  sentiment,
                  style: GoogleFonts.ptSans(
                      color: Colors.grey.shade800, fontSize: 30),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .8),
                height: MediaQuery.of(context).size.height * .06,
                width: MediaQuery.of(context).size.width * .9,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .02,
                  ),
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a sentence...',
                      suffixIcon: GestureDetector(
                        child: const Icon(Icons.navigate_next),
                        onTap: () async {
                          final result = await getValue(_controller.text);
                          setState(() {
                            sentiment = result;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> getValue(String input) async {
  try {
    List<dynamic> result = await querySentiment(input);
    final scores = result[0];
    String label = "";
    double score = 0;

    for (var entery in scores) {
      if (entery['score'] > score) {
        score = entery['score'];
        label = entery['label'].toString();
      }
    }
    return "$label ${(score * 100).toStringAsFixed(0)}%";
  } catch (e) {
    return e.toString();
  }
}

Future<List<dynamic>> querySentiment(String input) async {
  const String apiUrl =
      "https://api-inference.huggingface.co/models/lxyuan/distilbert-base-multilingual-cased-sentiments-student";
  const String token =
      "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"; // Replace with your token
  int retryCount = 0;
  const int maxRetries = 5;
  const Duration delay = Duration(seconds: 5);
  while (retryCount < maxRetries) {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({"inputs": input}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      final responseBody = json.decode(response.body);
      if (responseBody.containsKey('error') &&
          responseBody['error'].contains('is currently loading')) {
        retryCount++;
        await Future.delayed(delay);
      } else {
        throw Exception('Failed to load sentiment data: ${response.body}');
      }
    }
  }

  throw Exception('Model did not load in time. Please try again later.');
}

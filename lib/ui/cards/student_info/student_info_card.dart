import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/theme/darkmode_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StudentInfoCard extends StatefulWidget {
  StudentInfoCard();
  @override
  _StudentInfoCardState createState() => _StudentInfoCardState();
}

class _StudentInfoCardState extends State<StudentInfoCard> with WidgetsBindingObserver{
  String cardId = "student_info";
  WebViewController _webViewController;
  String url;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // observer for theme change, widget rebuilt on change
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () {
        reloadWebViewWithTheme(context, url, _webViewController);
      },
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
    );
  }

  double _contentHeight = cardContentMinHeight;
  //final _url = "https://cwo-test.ucsd.edu/WebCards/student_info_kevin.html";
  String fileURL = "https://cwo-test.ucsd.edu/WebCards/student_info_new.html";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  Widget buildCardContent(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      /// Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
      };
    }
    var tokenQueryString =
        "token=" + '${_userDataProvider.authenticationModel.accessToken}';

    url = fileURL + "?" + tokenQueryString;
    //var url = _url + "?" + tokenQueryString;
    reloadWebViewWithTheme(context, url, _webViewController);

    return Container(
        height: _contentHeight,
        child: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: url,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            javascriptChannels: <JavascriptChannel>[
              _printJavascriptChannel(context),
            ].toSet(),
            onPageFinished: (some) async {
              double height = double.parse(await _webViewController
                  .evaluateJavascript("document.documentElement.offsetHeight"));
              if (_contentHeight != height) {
                setState(() {
                  if (height <= cardContentMinHeight) {
                    _contentHeight = cardContentMinHeight;
                  } else if (height >= cardContentMaxHeight) {
                    _contentHeight = cardContentMaxHeight;
                  } else
                    _contentHeight = height;
                });
              }
            }));
  }

  //Channel to obtain links and open them in new browser
  JavascriptChannel _printJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'CampusMobile',
      onMessageReceived: (JavascriptMessage message) {
        openLink(message.message);
      },
    );
  }

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      //can't launch url, there is some error
    }
  }
}

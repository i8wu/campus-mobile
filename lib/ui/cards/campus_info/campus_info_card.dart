import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/theme/darkmode_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:campus_mobile_experimental/ui/theme/app_layout.dart';

class CampusInfoCard extends StatefulWidget{
  CampusInfoCard();
  @override
  _CampusInfoCardState createState() => _CampusInfoCardState();
}

class _CampusInfoCardState extends State<CampusInfoCard> with WidgetsBindingObserver {
  String cardId = "campus_info";
  WebViewController _webViewController;
  String _url = "https://cwo-test.ucsd.edu/WebCards/campus_info.html?dummy=true";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        reloadWebViewWithTheme(context, _url, _webViewController);
      },
      isLoading: false,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: null,
      child: () => buildCardContent(context),
    );
  }

  double _contentHeight = cardContentMinHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget buildCardContent(BuildContext context) {
    reloadWebViewWithTheme(context, _url, _webViewController);
    return Container(
      height: _contentHeight,
      child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: _url,
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          javascriptChannels: <JavascriptChannel>[
            _printJavascriptChannel(context),
          ].toSet(),
          onPageFinished: (some) async {
            double height = double.parse(await _webViewController
                .evaluateJavascript("document.documentElement.offsetHeight"));
            if (_contentHeight != double.parse(height.toString())) {
              setState(() {
                if (double.parse(height.toString()) <= cardContentMinHeight) {
                  _contentHeight = cardContentMinHeight;
                } else if (double.parse(height.toString()) >=
                    cardContentMaxHeight) {
                  _contentHeight = cardContentMaxHeight;
                } else
                  _contentHeight = double.parse(height.toString());
              });
            }
          }),
    );
  }

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

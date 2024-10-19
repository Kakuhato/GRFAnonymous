import 'package:flutter/cupertino.dart';
import 'package:grfanonymous/pages/homePage.dart';

GlobalKey<HomePageState> homeScaffoldKey = GlobalKey<HomePageState>();

HomePageState? get homeScaffoldState => homeScaffoldKey.currentState;

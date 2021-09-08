import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dana/screens/pages/camera_screen/nested_screens/create_post_screen.dart';
import 'package:dana/services/core/filtered_image_converter.dart';
import 'package:dana/services/core/liquid_swipe_pages.dart';
import 'package:dana/utilities/filters.dart';
import 'package:dana/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class EditPhotoScreen extends StatefulWidget {
  final File imageFile;
  final Function backToHomeScreen;

  EditPhotoScreen({@required this.imageFile, this.backToHomeScreen});
  @override
  _EditPhotoScreenState createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen>
    with TickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  TabController _tabController;
  LiquidController _liquidController = LiquidController();
  List<Container> _filterPages;
  String _filterTitle = '';
  bool _newFilterTitle = false;

  int _selectedIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    setState(() {
      _filterPages = LiquidSwipePagesService.getImageFilteredPaged(
          imageFile: widget.imageFile, height: size.width, width: size.width);
    });

    return Stack(
      children: [
        Container(
          height: double.infinity,
          color: darkColor,
          child: Image.asset(
            'assets/images/background.png',
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "Edit Photo",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: darkColor,
            brightness: Brightness.dark,
            iconTheme: IconThemeData(color: Colors.white),
            actions: [
              Padding(
                  padding: const EdgeInsets.only(right: 15, top: 17),
                  child: GestureDetector(
                      onTap: convertFilteredImageToImageFile,
                      child: Text('Next',
                          style:
                              TextStyle(color: Colors.white, fontSize: 20)))),
            ],
          ),
          body: Column(
            children: [
              RepaintBoundary(
                  key: _globalKey,
                  child: Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: size.width,
                          maxHeight: size.width,
                        ),
                        child: LiquidSwipe(
                          pages: _filterPages,
                          onPageChangeCallback: (value) {
                            setState(() => _selectedIndex = value);
                            _setFilterTitle(value);
                          },
                          waveType: WaveType.liquidReveal,
                          liquidController: _liquidController,
                          ignoreUserGestureWhileAnimating: true,
                          enableLoop: true,
                        ),
                      ),
                      if (_newFilterTitle) _displayStoryTitle(size),
                    ],
                  )),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: SizedBox()),
                    Container(
                      color: Theme.of(context).backgroundColor,
                      alignment: Alignment.center,
                      child: Container(
                        height: 140,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filters.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      _buildFilterThumbnail(index, size),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        filters[index].name,
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  setState(() => _selectedIndex = index);
                                  _liquidController.jumpToPage(page: index);
                                },
                              );
                            }),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Text('Filters',
                            style: TextStyle(color: Colors.white, fontSize: 20))
                        // TabBar(
                        //   controller: _tabController,
                        //   indicatorWeight: 3.0,
                        //   indicatorColor: Colors.blue,
                        //   labelColor: Colors.blue,
                        //   labelStyle: TextStyle(
                        //     fontSize: 18.0,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        //   unselectedLabelStyle: TextStyle(fontSize: 18.0),
                        //   unselectedLabelColor:
                        //       Theme.of(context).accentColor.withOpacity(0.7),
                        //   tabs: <Widget>[
                        //     Tab(text: 'Filters'),
                        //   ],
                        // ),
                        ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void convertFilteredImageToImageFile() async {
    File file = await FilteredImageConverter.convert(globalKey: _globalKey);
    Navigator.of(_globalKey.currentContext).push(
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
            imageFile: file, backToHomeScreen: widget.backToHomeScreen),
      ),
    );
  }

  Container _buildFilterThumbnail(int index, Size size) {
    final Image image = Image.file(
      widget.imageFile,
      width: size.width,
      fit: BoxFit.cover,
    );

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(
            color: _selectedIndex == index
                ? Colors.blue
                : Theme.of(context).primaryColor,
            width: 4.0),
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(filters[index].matrixValues),
        child: Container(
          height: 80,
          width: 80,
          child: image,
        ),
      ),
    );
  }

  void _setFilterTitle(title) {
    setState(() {
      _filterTitle = filters[title].name;
      _newFilterTitle = true;
    });
    Timer(Duration(milliseconds: 1000), () {
      if (_filterTitle == filters[title].name) {
        setState(() => _newFilterTitle = false);
      }
    });
  }

  Align _displayStoryTitle(Size screenSize) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: screenSize.width * 0.49),
        child: Text(
          _filterTitle,
          style: TextStyle(
              fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

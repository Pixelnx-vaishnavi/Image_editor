import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  late bool visibility;


  HomePage(
      {
        required this.visibility,
      }
      );
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;
  bool textap = false ;
  bool imageTap = false;
  bool elements = false;

  @override
  Widget build(BuildContext context) {

    final pages = [
      // CanvasScreenNew(textap: textap!,elemnetTap: false,imageTap: false,),
      // CanvasScreenNew(textap: textap!,elemnetTap: elements,imageTap: false,),
      // CanvasScreenNew(textap: textap!,elemnetTap: elements,imageTap: imageTap,),
      // CanvasScreenNew(textap: textap!,elemnetTap: elements,imageTap: false,),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffC4DFCB),

      body: pages[pageIndex],

      bottomNavigationBar: (pageIndex == 0 || pageIndex == 1 || pageIndex == 2)
          ? Visibility(
          visible: (textap == true)
              ? false
              : (elements == true)
              ? false
              : true,
          child: buildMyNavBar(context)
      )
          : null,
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                textap = true;
                pageIndex = 0;

              });
              // Navigator.push(context, MaterialPageRoute(builder: (context) {
              //   return  CanvasScreenNew(textap: textap!);
              // },));
            },
            icon: pageIndex == 0
                ? const Icon(
              Icons.text_fields_sharp,
              color: Colors.white,
              size: 35,
            )
                : const Icon(
              Icons.text_fields_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),

          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                elements = true;
                pageIndex = 1;
              });
            },
            icon: pageIndex == 1
                ? const Icon(
              Icons.widgets_rounded,
              color: Colors.white,
              size: 35,
            )
                : const Icon(
              Icons.widgets_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),

          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                imageTap = true;

                pageIndex = 2;
              });
            },
            icon: pageIndex == 2
                ? const Icon(
              Icons.photo,
              color: Colors.white,
              size: 35,
            )
                : const Icon(
              Icons.photo_size_select_actual_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                textap = true;
                pageIndex = 3;
              });
            },
            icon: pageIndex == 3
                ? const Icon(
              Icons.person,
              color: Colors.white,
              size: 35,
            )
                : const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
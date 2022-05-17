import 'package:flutter/material.dart';

class GraphicsKeyboard {
  static Map graphicsUnicode = {
    "┃": 179,
    "━": 196,
    "┏" : 218,
    "┳": 194,
    "┓": 191,
    "┣": 195,
    "╋": 197,
    "┫": 180,
    "┗": 192,
    "┻": 193,
    "┛": 217
  };



  static Widget keyboard(Function(String) callback) {
    return Container(
      width: 200,
      height: 200,
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(onTap: () {callback("┃");}, child: Text("┃", style: TextStyle(fontSize: 24,),)),
              Spacer(),
              GestureDetector(onTap: () {callback("━");}, child: Text("━", style: TextStyle(fontSize: 24,),)),
            ],
          ),
          Spacer(),
          Row(
            children: [
              GestureDetector(onTap: () {callback("┏");}, child: Text("┏", style: TextStyle(fontSize: 24,),)),
              Spacer(),
              GestureDetector(onTap: () {callback("┳");}, child: Text("┳", style: TextStyle(fontSize: 24,),)),
              Spacer(),
              GestureDetector(onTap: () {callback("┓");}, child: Text("┓", style: TextStyle(fontSize: 24,),)),
            ],
          ),
          Spacer(),
          Row(
            children: [
              GestureDetector(onTap: () {callback("┣");}, child: Text("┣", style: TextStyle(fontSize: 24,),)),
              Spacer(),
              GestureDetector(onTap: () {callback("╋");}, child: Text("╋", style: TextStyle(fontSize: 24,),)),
              Spacer(),
              GestureDetector(onTap: () {callback("┫");}, child: Text("┫", style: TextStyle(fontSize: 24,),)),
            ],
          ),
          Spacer(),
          Row(
            children: [
              GestureDetector(onTap: () {callback("┗");}, child: Text("┗", style: TextStyle(fontSize: 24,),)),
              Spacer(),
              GestureDetector(onTap: () {callback("┻");}, child: Text("┻", style: TextStyle(fontSize: 24,),)),
              Spacer(),
              GestureDetector(onTap: () {callback("┛");}, child: Text("┛", style: TextStyle(fontSize: 24,),)),
            ],
          ),

        ],
      ),
    );
  }
}

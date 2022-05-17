import 'package:flutter/material.dart';
import 'GRAMModel.dart';

enum CL {
  label,
  secondaryLabel,
  tertiaryLabel,
  quaternaryLabel,
  systemFill,
  secondarySystemFill,
  tertiarySystemFill,
  quaternarySystemFill,
  placeholderText,
  systemBackground,
  secondarySystemBackground,
  tertiarySystemBackground,
  systemGroupedBackground,
  secondarySystemGroupedBackground,
  tertiarySystemGroupedBackground,
  separator,
  opaqueSeparator,
  link,
  darkText,
  lightText,
  systemBlue,
  systemBrown,
  systemGreen,
  systemIndigo,
  systemOrange,
  systemPink,
  systemPurple,
  systemRed,
  systemTeal,
  systemYellow,
  systemGray,
  systemGray2,
  systemGray3,
  systemGray4,
  systemGray5,
  systemGray6,
  white,
  clear,
  lightGray
}

enum WN {
  backgroundViewColor,
  normalTextColor,

  // Visor
  backgroundColor, // El del visor
  tableBackgroundColor,
  alternateTableBackgroundColor,
  digitsTextColor,

  // Limits

  okColor,
  digitsTextColorOk,
  lowColor,
  digitsTextColorLow,
  highColor,
  digitsTextColorHigh,


  // Buttons
  buttonColor, // Normal button
  alternativeButtonColor, // "C"

  activeButtonColor, // Not Used
  inactiveButtonColor, // Not Used

  buttonTextColor, // Normal button text

  indicatorInactive, // Indicator Levels
  indicatorLevel_0,
  indicatorLevel_1,
  indicatorLevel_2,

  // Tare Button
  tareButtonColor,
  tareButtonText,

  // Link Buttons
  linkButtonColor
}

class CC {

  static decimalColor(double red, double green, double blue, double alpha) {
    return Color.fromARGB(
        (alpha * 255).floor(), (red * 255).floor(), (green * 255).floor(),
        (blue * 255).floor());
  }

  static var cccolors = {

    CL.label: [Color(0xff000000), Color(0xffffffff)],
    CL.secondaryLabel: [Color(0x993c3c43), Color(0x99ebebf5)],
    CL.tertiaryLabel: [Color(0x4c3c3c43), Color(0x4cebebf5)],
    CL.quaternaryLabel: [Color(0x2d3c3c43), Color(0x2debebf5)],
    CL.systemFill: [Color(0x33787880), Color(0x5b787880)],
    CL.secondarySystemFill: [Color(0x28787880), Color(0x51787880)],
    CL.tertiarySystemFill: [Color(0x1e767680), Color(0x3d767680)],
    CL.quaternarySystemFill: [Color(0x14747480), Color(0x2d767680)],
    CL.placeholderText: [Color(0x4c3c3c43), Color(0x4cebebf5)],
    CL.systemBackground: [Color(0xffffffff), Color(0xff000000)],
    CL.secondarySystemBackground: [Color(0xfff2f2f7), Color(0xff1c1c1e)],
    CL.tertiarySystemBackground: [Color(0xffffffff), Color(0xff2c2c2e)],
    CL.systemGroupedBackground: [Color(0xfff2f2f7), Color(0xff000000)],
    CL.secondarySystemGroupedBackground: [Color(0xffffffff), Color(0xff1c1c1e)],
    CL.tertiarySystemGroupedBackground: [Color(0xfff2f2f7), Color(0xff2c2c2e)],
    CL.separator: [Color(0x493c3c43), Color(0x99545458)],
    CL.opaqueSeparator: [Color(0xffc6c6c8), Color(0xff38383a)],
    CL.link: [Color(0xff007aff), Color(0xff0984ff)],
    CL.darkText: [Color(0xff000000), Color(0xff000000)],
    CL.lightText: [Color(0x99ffffff), Color(0x99ffffff)],
    CL.systemBlue: [Color(0xff007aff), Color(0xff0a84ff)],
    CL.systemGreen: [Color(0xff24c759), Color(0xff30d158)],
    CL.systemIndigo: [Color(0xff5856d6), Color(0xff5e5ce6)],
    CL.systemOrange: [Color(0xffff9500), Color(0xffff9f0a)],
    CL.systemPink: [Color(0xffff2d55), Color(0xffff375f)],
    CL.systemPurple: [Color(0xffaf52de), Color(0xffbf5af2)],
    CL.systemRed: [Color(0xffff3b30), Color(0xffff453a)],
    CL.systemTeal: [Color(0xff5ac8fa), Color(0xff64d2ff)],
    CL.systemYellow: [Color(0xffffcc00), Color(0xffffd60a)],
    CL.systemGray: [Color(0xff8e8e93), Color(0xff8e8e93)],
    CL.systemGray2: [Color(0xffaeaeb2), Color(0xff636366)],
    CL.systemGray3: [Color(0xffc7c7cc), Color(0xff48484a)],
    CL.systemGray4: [Color(0xffd1d1d6), Color(0xff3a3a3c)],
    CL.systemGray5: [Color(0xffe5e5ea), Color(0xff2c2c2e)],
    CL.systemGray6: [Color(0xfff2f2f7), Color(0xff1c1c1e)],
    CL.white: [Color(0xffffffff), Color(0xffffffff)],
    CL.clear : [Color(0x00000000), Color(0x00ffffff)],
    CL.lightGray : [Color(0xffd3d3d3), Color(0xffd3d3d3)],
  };


  static var widgetColors = {
    WN.backgroundViewColor: CL.systemBackground,
    WN.normalTextColor: CL.label,

    // Visor
    WN.backgroundColor: CL.systemGray4,
    // El del visor
    WN.tableBackgroundColor: CL.systemBackground,
    WN.alternateTableBackgroundColor: CL.systemGray4,
    WN.digitsTextColor: CL.label,

    // Limits

    WN.okColor: CL.systemGreen,
    WN.digitsTextColorOk: CL.darkText,
    WN.lowColor: CL.systemYellow,
    WN.digitsTextColorLow: CL.darkText,
    WN.highColor: CL.systemRed,
    WN.digitsTextColorHigh: CL.darkText,


    // Buttons
    WN.buttonColor: CL.secondaryLabel,
    //CL.systemGray2,  // Normal button
    WN.alternativeButtonColor: CL.systemRed,
    // "C"

    WN.activeButtonColor: CL.systemGreen,
    // Not Used
    WN.inactiveButtonColor: CL.systemGray2,
    // Not Used

    WN.buttonTextColor: CL.white,
    // Normal button text

    WN.indicatorInactive: CL.systemGray2,
    // Indicator Levels
    WN.indicatorLevel_0: CL.systemOrange,
    WN.indicatorLevel_1: CL.systemGreen,
    WN.indicatorLevel_2: CL.systemRed,

    // Tare Button
    WN.tareButtonColor: CL.systemYellow,
    WN.tareButtonText: CL.darkText,

    // Link Buttons
    WN.linkButtonColor: CL.secondaryLabel

  };

  static int theme(){
    //var th = GRAMModel.shared.darkMode ? "Dark" : "Clear";
    //print("Mode $th");
    return GRAMModel.shared.darkMode ? 1 : 0;
}

  static labelColor(CL label, int theme) {
    return (CC.cccolors[label])[CC.theme()];
  }

  static widgetColor(WN widget, int theme){
    return labelColor(CC.widgetColors[widget], CC.theme());
  }



}

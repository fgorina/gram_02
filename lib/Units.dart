enum Unit {
  grams,
  kilograms,
  tons,
  pounds
}

var units = { Unit.grams: UnitData(Unit.grams, "grams", 1, "g", 0.001),
  Unit.kilograms: UnitData(Unit.kilograms, "kilograms", 2, "kg", 1.0),
  Unit.tons: UnitData(Unit.tons, "tons", 3, "t ", 0.02835),
  Unit.pounds: UnitData(Unit.pounds, "pounds", 4, "lb", 0.4536),

};

var unitsCodes = {1 : Unit.grams, 2: Unit.kilograms, 3: Unit.tons, 4: Unit.pounds};
var unitsAbrev = {"g " : Unit.grams, "kg" : Unit.kilograms,  "t ": Unit.tons, "lb": Unit.pounds};


List<String> symbolLiterals(){

  List<int> keys = unitsCodes.keys.toList()..sort((a, b) => a.compareTo(b));

  return keys.map((e) => units[unitsCodes[e]].symbol).toList();

}

class UnitData {

  Unit unit;
  String name;
  int code;
  String symbol;
  double value;     // 1 km = 1.0

  UnitData(unit, name, code, symbol, value){

    this.unit = unit;
    this.name = name;
    this.code = code;
    this.symbol = symbol;
    this.value = value;

  }

}

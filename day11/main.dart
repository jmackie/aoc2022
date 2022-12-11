import 'dart:io';

typedef Lines = List<String>;

typedef Worry = int;

class Item {
  final Worry worry;

  Item(this.worry);

  @override
  String toString() => this.worry.toString();
}

typedef Items = List<Item>;

class Monkey {
  Items items;
  int inspections = 0;
  final Worry Function(Worry) operation;
  final int divisibleByTest;
  final int throwIndexIfTrue;
  final int throwIndexIfFalse;

  Monkey(
      {required this.items,
      required this.operation,
      required this.divisibleByTest,
      required this.throwIndexIfTrue,
      required this.throwIndexIfFalse});

  factory Monkey.fromLines(Lines lines) {
    final monkeyLine = lines.removeAt(0);
    assert(monkeyLine.startsWith("Monkey"));

    const startingItemsLineStart = "Starting items: ";
    final startingItemsLine = lines.removeAt(0).trimLeft();

    if (!startingItemsLine.startsWith(startingItemsLineStart)) {
      throw "malformed starting items line: ${startingItemsLine}";
    }

    final startingItems = startingItemsLine
        .replaceFirst(startingItemsLineStart, "")
        .split(",")
        .map((s) => Item(int.parse(s)))
        .toList();

    const operationLineStart = "Operation: new = ";
    final operationLine = lines.removeAt(0).trimLeft();
    if (!operationLine.startsWith(operationLineStart)) {
      throw "malformed operation line: ${operationLine}";
    }
    final operation =
        operationLine.replaceFirst(operationLineStart, "").split(" ");

    const testLineStart = "Test: divisible by ";
    final testLine = lines.removeAt(0).trimLeft();
    if (!testLine.startsWith(testLineStart)) {
      throw "malformed test line: ${testLine}";
    }
    final divisbleByTest = int.parse(testLine.replaceFirst(testLineStart, ""));

    const ifTrueLineStart = "If true: throw to monkey ";
    final ifTrueLine = lines.removeAt(0).trimLeft();
    if (!ifTrueLine.startsWith(ifTrueLineStart)) {
      throw "malformed `if true` line: ${ifTrueLine}";
    }
    final throwIndexIfTrue =
        int.parse(ifTrueLine.replaceFirst(ifTrueLineStart, ""));

    const ifFalseLineStart = "If false: throw to monkey ";
    final ifFalseLine = lines.removeAt(0).trimLeft();
    if (!ifFalseLine.startsWith(ifFalseLineStart)) {
      throw "malformed `if false` line: ${ifFalseLine}";
    }
    final throwIndexIfFalse =
        int.parse(ifFalseLine.replaceFirst(ifFalseLineStart, ""));

    return Monkey(
        items: startingItems,
        divisibleByTest: divisbleByTest,
        throwIndexIfTrue: throwIndexIfTrue,
        throwIndexIfFalse: throwIndexIfFalse,
        operation: (worry) {
          final lhs = operation[0] == "old" ? worry : int.parse(operation[0]);
          final rhs = operation[2] == "old" ? worry : int.parse(operation[2]);
          switch (operation[1]) {
            case "*":
              return lhs * rhs;
            case "+":
              return lhs + rhs;
            default:
              throw "unknown operator: ${operation[1]}";
          }
        });
  }

  @override
  String toString() =>
      "Monkey(${this.items.toString()}, ${this.divisibleByTest}, ${this.throwIndexIfTrue}, ${this.throwIndexIfFalse})";
}

typedef Monkeys = List<Monkey>;

Monkeys monkeysFromInput(String inputFile) {
  final Monkeys monkeys = [];

  Lines currentMonkeyLines = [];
  new File(inputFile).readAsLinesSync().forEach((line) {
    if (line == "") {
      monkeys.add(Monkey.fromLines(currentMonkeyLines));
      currentMonkeyLines = [];
      return;
    }
    currentMonkeyLines.add(line);
  });

  if (currentMonkeyLines.length > 0) {
    monkeys.add(Monkey.fromLines(currentMonkeyLines));
  }
  return monkeys;
}

bool isDivisibleBy(x, y) => y % x == 0;

void throwingRound(Monkeys monkeys, Worry Function(Worry) manageWorry) {
  for (var i = 0; i < monkeys.length; i++) {
    final monkey = monkeys[i];
    while (monkey.items.length > 0) {
      final item = monkey.items.removeAt(0);
      final worry = manageWorry(monkey.operation(item.worry));

      if (isDivisibleBy(monkey.divisibleByTest, worry)) {
        monkeys[monkey.throwIndexIfTrue].items.add(Item(worry));
      } else {
        monkeys[monkey.throwIndexIfFalse].items.add(Item(worry));
      }

      monkey.inspections++;
    }
  }
}

int solve(Monkeys monkeys, int nrounds, Worry Function(Worry) manageWorry) {
  for (var round = 0; round < nrounds; round++) {
    throwingRound(monkeys, manageWorry);
  }
  final totalInspections = monkeys.map((monkey) => monkey.inspections).toList();
  totalInspections.sort();

  final monkeyBusiness =
      totalInspections.reversed.take(2).reduce((x, y) => x * y);

  return monkeyBusiness;
}

int partOne(Monkeys monkeys) =>
    solve(monkeys, 20, (worry) => (worry / 3).floor());

int partTwo(Monkeys monkeys) {
  final mod =
      monkeys.map((monkey) => monkey.divisibleByTest).reduce((x, y) => x * y);

  return solve(monkeys, 10000, (worry) => worry % mod);
}

void main(List<String> args) {
  final inputFile = args[0];

  final partOneAnswer = partOne(monkeysFromInput(inputFile));
  if (partOneAnswer != 120384) {
    throw "wrong answer to part one";
  }
  print("part one: ${partOneAnswer}");

  final partTwoAnswer = partTwo(monkeysFromInput(inputFile));
  if (partTwoAnswer != 32059801242) {
    throw "wrong answer to part two";
  }
  print("part two: ${partTwoAnswer}");
}

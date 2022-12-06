let
  inherit (builtins) readFile genList stringLength foldl' length substring seq;

  pkgs = import <nixpkgs> { };
  inherit (pkgs.lib) flip assertMsg;
  inherit (pkgs.lib.strings) stringToCharacters;
  inherit (pkgs.lib.lists) unique;

  rangeAlongString = s: genList (i: i) (stringLength s);

  findMarker = windowLen: input:
    let
      allCharsAreDifferent = s:
        let chars = stringToCharacters s;
        in length (unique chars) == length chars;
    in
    foldl'
      (result: start:
        if !isNull result
        then result # break
        else
          let window = substring start windowLen input; in
          if allCharsAreDifferent window
          then start + windowLen
          else null # continue
      )
      null
      (rangeAlongString input);

  afterTests = x:
    let
      test0 = assertMsg (findMarker 4 "mjqjpqmgbljsphdztnvjfqwrcgsmlb" == 7) "test0 failed";
      test1 = assertMsg (findMarker 4 "bvwbjplbgvbhsrlpgdmjqwftvncz" == 5) "test1 failed";
      test2 = assertMsg (findMarker 4 "nppdvjthqldpwncqszvftbrmjlhg" == 6) "test2 failed";
      test3 = assertMsg (findMarker 4 "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" == 10) "test3 failed";
      test4 = assertMsg (findMarker 4 "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" == 11) "test4 failed";
      test5 = assertMsg (findMarker 14 "mjqjpqmgbljsphdztnvjfqwrcgsmlb" == 19) "test5 failed";
      test6 = assertMsg (findMarker 14 "bvwbjplbgvbhsrlpgdmjqwftvncz" == 23) "test6 failed";
      test7 = assertMsg (findMarker 14 "nppdvjthqldpwncqszvftbrmjlhg" == 23) "test7 failed";
      test8 = assertMsg (findMarker 14 "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsggvjw" == 29) "test8 failed";
      test9 = assertMsg (findMarker 14 "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" == 26) "test9 failed";
    in
    foldl' (flip seq) x [ test0 test1 test2 test3 test4 test5 test6 test7 test8 test9 ];

  partOne = findMarker 4;
  partTwo = findMarker 14;

  main = input: afterTests {
    "part one" = partOne input;
    "part two" = partTwo input;
  };
in
main (readFile ./input.txt)

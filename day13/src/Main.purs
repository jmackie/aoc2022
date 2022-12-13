module Main where

import Prelude

import Control.Alt ((<|>))
import Control.Lazy (defer)
import Data.Array as Array
import Data.Either (Either(..), either)
import Data.FoldableWithIndex (foldlWithIndex)
import Data.FunctorWithIndex (mapWithIndex)
import Data.List (List(..), (:))
import Data.List as List
import Data.List.NonEmpty (NonEmptyList(..))
import Data.Maybe (Maybe(..), maybe)
import Data.NonEmpty (NonEmpty(..))
import Data.Semigroup.Foldable (intercalateMap)
import Data.String as String
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..), uncurry)
import Effect (Effect)
import Effect.Console as Console
import Effect.Exception as Exception
import Node.Encoding (Encoding(..))
import Node.FS.Sync as File
import Node.Process as Process
import Parsing (ParseError, parseErrorMessage)
import Parsing (Parser, runParser) as Parse
import Parsing.Combinators (between, sepBy) as Parse
import Parsing.String (string) as Parse
import Parsing.String.Basic (intDecimal) as Parse

main :: Effect Unit
main = Process.argv >>= Array.unsnoc >>> case _ of
  Just { last: inputFile } -> do
    input <- File.readTextFile UTF8 inputFile
    pairs <- either (parseErrorMessage >>> Exception.throw) pure (processInput input)

    --  Use this to debug that the input was parsed correctly
    --for_ pairs \(Tuple packets packets') -> do
    --  Console.log (showPackets packets)
    --  Console.log (showPackets packets')
    --  Console.log ""

    let partOneAnswer = solvePartOne pairs
    unless (partOneAnswer == 5185) $ Exception.throw "wrong answer to part one!"
    Console.log ("part one: " <> show partOneAnswer)

    let flattened = List.foldl (\ls (Tuple x y) -> x : y : ls) Nil pairs
    let partTwoAnswer = solvePartTwo flattened
    unless (partTwoAnswer == 23751) $ Exception.throw "wrong answer to part two!"
    Console.log ("part two: " <> show partTwoAnswer)

  _ -> Exception.throw "no input file specified!"

solvePartOne :: List Pairs -> Int
solvePartOne =
  flip foldlWithIndex 0
    \i sum (Tuple packets packets') ->
      if compare (PacketList packets) (PacketList packets') == LT then sum + i + 1 else sum

solvePartTwo :: List Packets -> Int
solvePartTwo packets =
  let
    divider2Index = List.findIndex (_ == divider2) sortedPackets
    divider6Index = List.findIndex (_ == divider6) sortedPackets
  in
    maybe 1 (_ + 1) divider2Index * maybe 1 (_ + 1) divider6Index
  where
  sortedPackets = List.sort (divider2 : divider6 : packets)

  divider2 :: Packets
  divider2 = mkDivider 2

  divider6 :: Packets
  divider6 = mkDivider 6

  mkDivider n = List.singleton (PacketList (List.singleton (PacketInt n)))

type Pairs = Tuple Packets Packets

processInput :: String -> Either ParseError (List Pairs)
processInput input = do
  let lines = splitLines input
  parsedLines <- List.fromFoldable <$> traverse parse lines
  let
    { yes: evenPackets, no: oddPackets } =
      List.partition
        (\(Tuple i _) -> isEven i)
        (mapWithIndex Tuple parsedLines)

  Right $ List.zipWith
    (\(Tuple _ packets) (Tuple _ packets') -> Tuple packets packets')
    evenPackets
    oddPackets
  where
  parse :: String -> Either ParseError Packets
  parse s = Parse.runParser s (listParser packetParser)

  splitLines :: String -> Array String
  splitLines = String.split (String.Pattern "\n") >>> Array.filter (_ /= "")

  isEven x = x `mod` 2 == 0

type Packets = List Packet

data Packet
  = PacketInt Int
  | PacketList Packets

instance eqPacket :: Eq Packet where
  eq (PacketInt x) (PacketInt y) = x == y
  eq (PacketList xs) (PacketList ys)
    | List.length xs == List.length ys = List.all (uncurry eq) (List.zip xs ys)
    | otherwise = false
  eq _ _ = false

instance ordPacket :: Ord Packet where
  compare (PacketInt x) (PacketInt y) = compare x y
  compare x@(PacketInt _) ys = compare (PacketList (List.singleton x)) ys
  compare xs y@(PacketInt _) = compare xs (PacketList (List.singleton y))
  compare (PacketList Nil) (PacketList Nil) = EQ
  compare (PacketList Nil) (PacketList _) = LT
  compare (PacketList _) (PacketList Nil) = GT
  compare (PacketList (Cons x xs)) (PacketList (Cons y ys)) =
    compare x y <> compare (PacketList xs) (PacketList ys)

instance showPacket :: Show Packet where
  show (PacketInt i) = show i
  show (PacketList ls) = showPackets ls

showPackets :: Packets -> String
showPackets Nil = "[]"
showPackets (Cons head tail) = "[" <> intercalateMap "," show ne <> "]"
  where
  ne = NonEmptyList (NonEmpty head tail)

type Parser = Parse.Parser String

packetParser :: Parser Packet
packetParser = defer \_ -> packetIntParser <|> packetListParser

packetIntParser :: Parser Packet
packetIntParser = PacketInt <$> Parse.intDecimal

packetListParser :: Parser Packet
packetListParser = defer \_ -> PacketList <$> listParser packetParser

listParser :: forall a. Parser a -> Parser (List a)
listParser p = Parse.between openBracket closeBracket (p `Parse.sepBy` comma)
  where
  openBracket = Parse.string "["
  closeBracket = Parse.string "]"
  comma = Parse.string ","

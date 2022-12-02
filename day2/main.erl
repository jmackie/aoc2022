-module(main).

-export([main/1]).

% escript entry point
main([InputFile]) ->
    {ok, BinaryInput} = file:read_file(InputFile),
    Input = binary:bin_to_list(BinaryInput),
    InputLines = string:split(string:trim(Input), "\n", all),
    PartOneResult = 12276 = part_one(InputLines),
    PartTwoResult = 9975 = part_two(InputLines),

    io:format("part one: ~p~n", [PartOneResult]),
    io:format("part two: ~p~n", [PartTwoResult]);
main(_) ->
    usage().

usage() ->
    io:format("usage: main.erl <INPUT_FILE> \n"),
    halt(1).

part_one(InputLines) ->
    lists:foldl(
        fun(Line, Score) ->
            [TheirMoveRaw, OurMoveRaw] = string:split(Line, " "),
            TheirMove = parse_move(TheirMoveRaw),
            OurMove = parse_move(OurMoveRaw),
            Outcome = get_outcome_from_moves({TheirMove, OurMove}),
            Score + score_for_outcome(Outcome) + score_for_shape(OurMove)
        end,
        0,
        InputLines
    ).

part_two(InputLines) ->
    lists:foldl(
        fun(Line, Score) ->
            [TheirMoveRaw, RequiredOutcomeRaw] = string:split(Line, " "),
            TheirMove = parse_move(TheirMoveRaw),
            RequiredOutcome = parse_required_outcome(RequiredOutcomeRaw),
            OurMove = get_move_from_outcome({TheirMove, RequiredOutcome}),
            Score + score_for_outcome(RequiredOutcome) + score_for_shape(OurMove)
        end,
        0,
        InputLines
    ).

parse_move("A") -> rock;
parse_move("B") -> paper;
parse_move("C") -> scissors;
parse_move("X") -> rock;
parse_move("Y") -> paper;
parse_move("Z") -> scissors.

parse_required_outcome("X") -> loss;
parse_required_outcome("Y") -> draw;
parse_required_outcome("Z") -> win.

% rock defeats scissors
get_outcome_from_moves({rock, scissors}) -> loss;
get_outcome_from_moves({scissors, rock}) -> win;
% scissors defeats paper
get_outcome_from_moves({scissors, paper}) -> loss;
get_outcome_from_moves({paper, scissors}) -> win;
% paper defeats rock
get_outcome_from_moves({paper, rock}) -> loss;
get_outcome_from_moves({rock, paper}) -> win;
% draw
get_outcome_from_moves(_) -> draw.

% responses to rock
get_move_from_outcome({rock, loss}) -> scissors;
get_move_from_outcome({rock, draw}) -> rock;
get_move_from_outcome({rock, win}) -> paper;
% responses to paper
get_move_from_outcome({paper, loss}) -> rock;
get_move_from_outcome({paper, draw}) -> paper;
get_move_from_outcome({paper, win}) -> scissors;
% responses to scissors
get_move_from_outcome({scissors, loss}) -> paper;
get_move_from_outcome({scissors, draw}) -> scissors;
get_move_from_outcome({scissors, win}) -> rock.

score_for_shape(rock) -> 1;
score_for_shape(paper) -> 2;
score_for_shape(scissors) -> 3.

score_for_outcome(loss) -> 0;
score_for_outcome(draw) -> 3;
score_for_outcome(win) -> 6.

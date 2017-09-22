-module(numerals).
-export([r/1, largestN/1, repeat/2]).

% Convert numbers to roman numerals
% Examples:
%% 1: I, 2: II, 3: III, 4: IV, 5: V, 7: VII, 8: VIII, 9: IX, 10: X
%% 13: XIII, 14: XIV, 15: XV, 19: XIX, 20: XX
% Notes:
%% There are a set of symbols representing magnitudes, S, [I, V, X, L, C]
%% This set, S, converts to digits, N, [1, 5, 10, 50, 100].
%% S(0) = I, S(3) = L, N(3) = 50.
%% Any number less than N(n), can be represented using sumbols {S(i) | i in {0..n-1}}.
%% The number N(n)-1 is represented as N(0)N(n).
%% For Even(n)
%%   The number N(n)-N(n-1) is represented as S(n-1)
%%   Examples: N(2)-N(1) = 5   is represented as S(1) = V
%%             N(4)- N(3) = 50 is represented as S(3) = L
%% For Odd(n)
%%   The number N(n)-N(n-1) is represented as S(n-1)S(n)
%%   Examples: N(3)-N(2) = 40 is represented as S(2)S(3) = XL
%%             N(1)-N(0) = 4  is represented as S(0)S(1) = IV
%% For Even(n)
%%   Examples: The number N(n)-N(n-1)-N(n-2)  is represented as S(n-2)S(n-1)
%%             The number N(2)-N(1)-N(0) = 4  is represented as S(n-2)S(n-1) = IV
%%             The number N(n)-N(n-1)-2N(n-2) is represented as 3S(n-2) = III
%%             The number N(n)-2N(n-1) is always 0.
%%   
%% For N(0) to N(1):
%%   N(0), N(0)N(0), N(0)N(0)N(0), N(0)N(1), N(1)
%% For N(1) to N(2):
%%   N(1), N(1)N(0), N(1)N(0)N(0), N(1)N(0)N(0)N(0), N(0)N(2), N(2)
%% For N(2) to N(3):
%% N(2), N(2)N(0), .., N(2)N(0)N(0)N(0), N(2)N(0)N(1), N(2)N(1), N(2)N(1)N(0), .., N(0)N(2)N(2)
%%
%% Only a single S(n-1) may be in front of S(n).
%% Any number of S(0..n) may go behind S(n).
%%
%% For i = N(n)..N(n+1)
%%
% Idea:
%% Decompose input i into terms of N(n).
%% Start by finding the smallest value of N(n) that i is smaller than.
%% E.G. 39 -> N(3), S(3) -> L. R(39) result in XXXIX.
%% 

largestNA(I, [NH | [NNH | NT]], [SH | ST]) ->
	if NNH > I ->
			largestNA(I, [NNH | NT], ST);
		true ->
			{[NH | [NNH | NT]], [SH | ST]}
	end.
largestN(I) ->
	largestNA(I, [5000, 1000, 500, 100, 50, 10, 5, 1], ["**ERROR**", "M", "D", "C", "L", "X", "V", "I"]).

largestTens(I) ->
	largestNA(I, [5000, 1000, 100, 10, 1], ["**ERROR**", "M", "C", "X", "I"]).

repeat(_, 0) ->
	"";
repeat(S, R) ->
	S ++ repeat(S, R-1).

% Using the above cases.
r(0) ->
	"";
r([I]) ->
	[r(I)];
r([I | Is]) ->
	[r(I) | r(Is)];
r(I) ->
	{[NH | NT], [SH | ST]} = largestN(I),
	[NextSmallestN | _] = NT,
	%[EvenSmallerN | _] = NTT, 
	[NextSmallestS | _] = ST,
	{[_ | [NextSmallestTensN | _]], [_ | [NextSmallestTensS | _]]} = largestTens(I),
	if I == NextSmallestN ->
			NextSmallestS;
		I < (NH - NextSmallestTensN) -> % It will be composed of symbols not including SH
			%SomeNumber of NextSmallestS followed by r(SomeNumber * NextSmallestN - NH)
			SomeNumber = I div NextSmallestN,
			repeat(NextSmallestS, SomeNumber) ++ r(I - (SomeNumber * NextSmallestN));
		true -> % else it will be NextSmallestS.r(I - (NH - NextSmallestN)) : NH-I = between 0 and NextSmallestN
			NextSmallestTensS ++ SH ++ r(I - (NH - NextSmallestTensN))
	end.
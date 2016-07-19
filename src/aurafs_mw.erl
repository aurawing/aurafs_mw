%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 七月 2016 上午10:15
%%%-------------------------------------------------------------------
-module(aurafs_mw).
-author("aurawing").

%% API
-export([]).

-export_type([unixtime/0]).

-type unixtime() :: {integer(), integer(), integer()}. % {MegaSecs, Secs, MicroSecs}
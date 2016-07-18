%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 七月 2016 下午10:13
%%%-------------------------------------------------------------------
-module(aurafs_mw_file).
-author("aurawing").

-define(FILE_TBL, <<"file">>).

%% API
-export([]).

-export_type([file/0]).

-type file() :: #{ _Id :: binary() => {binary()},       % {"_id"=ObjectId("XXXXXX"),
                   Type :: binary() => f | d,           %  "type"="f",
                   Owner :: binary() => binary(),       %  "owner"="6a6878a878d89f898...",
                   Name :: binary() => binary(),        %  "name"="testfile.txt",
                   Pid :: binary() => binary(),         %  "pid"="556a768d8a6c6db7634cb3",
                   Apid :: binary() => [binary()],      %  "apid"=["556a768d8a6c6db7634cb3","a7bc7878d878a87f813512",...],
                   Identity :: binary() => binary(),    %  "identity"="7a987c8a87fb7987d8ae8979789a8126388a6786",
                   Maxver :: binary() => pos_integer(), %  "maxver"=1,
                   Versions :: binary() => [tuple()],   %  "versions"=[{"verno"}],
                   Ext :: binary() => maps() }.         %  "ext"={"X1":"Y1","X2","Y2",...} }




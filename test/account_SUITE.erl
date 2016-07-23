%%%-------------------------------------------------------------------
%%% @author aurawing
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% account测试
%%% @end
%%% Created : 20. 七月 2016 下午3:07
%%%-------------------------------------------------------------------
-module(account_SUITE).
-author("aurawing").

-include_lib("common_test/include/ct.hrl").

-export([all/0, init_per_suite/1, end_per_suite/1]).
%% Test
-export([create_account_test/1]).

all() -> [create_account_test].

init_per_suite(Config) ->
  ct:pal("init_per_suit executing!", []),
  Pid = spawn(fun() -> Result = application:ensure_all_started(aurafs_mw), ct:pal("Result is: ~p~n", [Result]), receive stop -> exit(normal) end end),
  [{pid, Pid} | Config].

end_per_suite(Config) ->
  ct:pal("end_per_suit executing!", []),
  ?config(pid, Config)!stop.

create_account_test(_Config) ->
  {ok, _Account} = aurafs_mw_account:create_account(aurafs_mw_digest:hex(uuid:uuid1()), <<"123456">>, -1).





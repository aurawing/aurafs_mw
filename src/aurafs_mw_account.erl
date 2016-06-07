%%%-------------------------------------------------------------------
%%% @author aurawing
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 六月 2016 下午9:13
%%%-------------------------------------------------------------------
-module(aurafs_mw_account).
-author("aurawing").

-define(ACCOUNT, <<"account">>).
%% API
-export([create_account/3]).

create_account(Username, Password, Space) ->
  Account = #{<<"username">> => Username,
              <<"password">> => aurafs_mw_digest:md5(Password),
              <<"token">> => aurafs_mw_digest:hex(uuid:uuid1()),
              <<"space">> => Space, <<"create_time">> => os:timestamp()},
  Ret = mongoc:transaction(mongo_reg,
    fun(Worker) ->
      mc_worker_api:insert(Worker, ?ACCOUNT, Account)
    end),
  Ret.

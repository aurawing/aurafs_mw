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

-define(ACCOUNT_TBL, <<"account">>).
%% API
-export([create_account/3, login_account/2]).

-export_type([account/0]).

-type account() :: #{ _Id :: binary() => {binary()},
                      Username :: binary() => binary(),
                      Password :: binary() => binary(),
                      Token :: binary() => binary(),
                      CreateTime :: binary() => tuple(),
                      Space :: binary() => integer()}.

-spec create_account(binary(), binary(), integer()) -> account().
create_account(Username, Password, Space) ->
  Token = aurafs_mw_digest:hex(uuid:uuid1()),
  Account = #{<<"username">> => Username,
              <<"password">> => aurafs_mw_digest:md5(Password),
              <<"token">> => Token,
              <<"space">> => Space,
              <<"create_time">> => os:timestamp()},
  {{true, Status}, Ret} = mongoc:transaction(mongo_reg,
    fun(Worker) ->
      mc_worker_api:insert(Worker, ?ACCOUNT_TBL, Account)
    end),
  case maps:is_key(<<"writeErrors">>, Status) of
    true -> throw({error, insert_failed, maps:get(<<"writeErrors">>, Status)});
    false -> Ret
  end.

%%% @doc
%%%
%%% @end
-spec login_account(binary(), binary()) -> account() | #{}.
login_account(Username, Password) ->
  mongoc:transaction_query(mongo_reg,
    fun(Conf) ->
      mongoc:find_one(Conf, ?ACCOUNT_TBL, #{<<"username">> => Username, <<"password">> => aurafs_mw_digest:md5(Password)}, #{}, 0)
    end).
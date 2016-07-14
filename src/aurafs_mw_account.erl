%%%-------------------------------------------------------------------
%%% @author aurawing
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% 用户帐号管理相关功能
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

%%% @doc
%%% 使用用户名、密码和空间大小创建帐号，空间大小为-1相当于无限制，如帐号已存在则返回错误信息
%%% @end
-spec create_account(binary(), binary(), integer()) -> {ok, account()} | {error, insert_failed, [tuple()]}.
create_account(Username, Password, Space) ->
  Token = aurafs_mw_digest:hex(uuid:uuid1()),
  Account = #{<<"username">> => Username,
              <<"password">> => aurafs_mw_digest:md5(Password),
              <<"token">> => Token,
              <<"space">> => Space,
              <<"create_time">> => os:timestamp()},
  {{true, Status}, Account} = mongoc:transaction(mongo_reg,
    fun(Worker) ->
      mc_worker_api:insert(Worker, ?ACCOUNT_TBL, Account)
    end),
  case maps:is_key(<<"writeErrors">>, Status) of
    true -> {error, insert_failed, maps:get(<<"writeErrors">>, Status)};
    false -> {ok, Account}
  end.

%%% @doc
%%% 使用帐号和密码登陆，并返回用户信息，登录失败返回空map
%%% @end
-spec login_account(binary(), binary()) -> account() | #{}.
login_account(Username, Password) ->
  mongoc:transaction_query(mongo_reg,
    fun(Conf) ->
      mongoc:find_one(Conf, ?ACCOUNT_TBL, #{<<"username">> => Username, <<"password">> => aurafs_mw_digest:md5(Password)}, #{}, 0)
    end).
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

-include("../include/account.hrl").
-include("../include/file.hrl").
-include("../include/errors.hrl").
-include("../include/log.hrl").

%% API
-export([create_account/3, login_account/2, authorize_account/1, is_super_user/1]).

-export_type([account/0]).

-type account() :: #{ _Id :: binary() => {binary()},    % {"_id"=ObjectId("XXXXXX"),
                      Username :: binary() => binary(), %   "username"="XXXXXX",
                      Password :: binary() => binary(), %   "password"="91285d1aef...",
                      Token :: binary() => binary(),    %   "token"="a5b75d4567f665e...",
                      CreateTime :: binary() => tuple(),%   "create_time"=new Date(),
                      Space :: binary() => integer(),   %   "space"=1024000,
                      RootDir :: binary() => binary()}. %   "root_dir"="6ab8c87d98..."}

%%% @doc
%%% 使用用户名、密码和空间大小创建帐号，空间大小为-1相当于无限制，如帐号已存在则返回错误信息
%%% @end
-spec create_account(binary(), binary(), integer()) -> {ok, account()} | aurafs_mw:insert_failed(tuple()).
create_account(Username, Password, Space) ->
  Token = aurafs_mw_digest:hex(uuid:uuid1()),
  RootDir = aurafs_mw_file:create_dir(?SUPER_USER_TOKEN, Token, ?ROOT_PID, os:timestamp(), os:timestamp(), #{}),
  Account = #{?A_USERNAME => Username,
              ?A_PASSWORD => aurafs_mw_digest:md5(Password),
              ?A_TOKEN => Token,
              ?A_SPACE => Space,
              ?A_CREATE_TIME => os:timestamp(),
              ?A_ROOT_DIR => maps:get(?F_ID, RootDir)},
  {{true, Status}, Account1} = mongoc:transaction(mongo_reg,
    fun(Worker) ->
      mc_worker_api:insert(Worker, ?ACCOUNT_TBL, Account)
    end),
  case maps:is_key(<<"writeErrors">>, Status) of
    true -> ?INSERT_FAILED(hd(maps:get(<<"writeErrors">>, Status)));
    false -> {ok, Account1}
  end.

%%% @doc
%%% 使用帐号和密码登陆，并返回用户信息，登录失败返回login_failed
%%% @end
-spec login_account(binary(), binary()) -> {ok, account()} | aurafs_mw:login_failed().
login_account(Username, Password) ->
  Account = mongoc:transaction_query(mongo_reg,
    fun(Conf) ->
      mongoc:find_one(Conf, ?ACCOUNT_TBL, #{?A_USERNAME => Username, ?A_PASSWORD => aurafs_mw_digest:md5(Password)}, #{}, 0)
    end),
  if
    Account == #{} -> throw(?LOGIN_FAILED);
    true -> {ok, Account}
  end.

%%% @doc
%%% 通过token获取用户信息，登录失败返回error
%%% @end
-spec authorize_account(binary()) -> {ok, account()} | aurafs_mw:unauthorized().
authorize_account(Token) ->
  Account = mongoc:transaction_query(mongo_reg,
    fun(Conf) ->
      mongoc:find_one(Conf, ?ACCOUNT_TBL, #{?A_TOKEN => Token}, #{}, 0)
    end),
  if
    Account == #{} -> ?UNAUTHORIZED;
    true -> {ok, Account}
  end.

%%% @doc
%%% 判断token是否属于超级用户
%%% @end
-spec is_super_user(binary()) -> boolean().
is_super_user(Token) ->
  Token==?SUPER_USER_TOKEN.
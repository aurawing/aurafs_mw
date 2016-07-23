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
-export([start/0]).

-export_type([unixtime/0]).

-type unixtime() :: {integer(), integer(), integer()}. % {MegaSecs, Secs, MicroSecs}

-export_type([login_failed/0, unauthorized/0, dir_access_denied/0, file_access_denied/0, no_dir/0, no_file/0, insert_failed/1]).
% 错误类型定义
-type login_failed() :: {error, login_failed}. %% 登录失败
-type unauthorized() :: {error, unauthorized}. %% 未授权的请求
-type dir_access_denied() :: {error, dir_access_denied}. %% 目录禁止访问
-type file_access_denied() :: {error, file_access_denied}. %% 文件禁止访问
-type no_dir() :: {error, no_dir}. %% 目录不存在
-type no_file() :: {error, no_file}. %% 文件不存在
-type insert_failed(Msg) :: {error, insert_failed, Msg}. %% 数据库插入失败

start() ->
  Result = application:ensure_all_started(aurafs_mw),
  receive
    stop -> ok
  end.
  %io:format("~p~n", [Result]),
  %{ok, _Account} = aurafs_mw_account:create_account(aurafs_mw_digest:hex(uuid:uuid1()), <<"123456">>, -1).
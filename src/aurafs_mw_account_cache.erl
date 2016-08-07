%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 七月 2016 下午3:34
%%%-------------------------------------------------------------------
-module(aurafs_mw_account_cache).
-author("aurawing").

-include("../include/account.hrl").
-include("../include/log.hrl").

%% API
-export([init/0, get/1]).

init() ->
  ets:new(?MODULE, [set, public, named_table, {write_concurrency, true}, {read_concurrency, true}]).

get(Token) ->
  case ets:lookup(?MODULE, Token) of
    [] -> fill_cache(aurafs_mw_account:authorize_account(Token));
    [{Token, Account}] -> Account
  end.

fill_cache({ok, Account}) ->
  #{?A_TOKEN := Token} = Account,
  true = ets:insert(?MODULE, {Token, Account}),
  Account;
fill_cache({error ,Reason}) ->
  throw({error, Reason}).


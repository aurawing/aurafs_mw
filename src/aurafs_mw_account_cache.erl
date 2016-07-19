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

%% API
-export([init/0, get/1]).

init() ->
  ets:new(?MODULE, [set, public, named_table, {write_concurrency, true}, {read_concurrency, true}]).

get(Token) ->
  case ets:lookup(?MODULE, Token) of
    [] -> process_result(aurafs_mw_account:authorize_account(Token));
    [{Token, Account}] -> {ok, Account}
  end.

process_result({ok, Account}) ->
  #{<<"token">> := Token} = Account,
  true = ets:insert(?MODULE, {Token, Account}),
  {ok, Account};
process_result({error ,Reason}) ->
  {error ,Reason}.


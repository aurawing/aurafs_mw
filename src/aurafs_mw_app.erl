%%%-------------------------------------------------------------------
%% @doc aurafs_mw public API
%% @end
%%%-------------------------------------------------------------------

-module(aurafs_mw_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, test/0]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    aurafs_mw_account_cache:init(),
    aurafs_mw_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
test() ->
    application:ensure_all_started(aurafs_mw),
    aurafs_mw_account:create_account(<<"test3">>, <<"123456">>, -1).
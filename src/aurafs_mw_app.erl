%%%-------------------------------------------------------------------
%% @doc aurafs_mw public API
%% @end
%%%-------------------------------------------------------------------

-module(aurafs_mw_app).

-behaviour(application).

-include("../include/log.hrl").

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    ?I("Starting account cache module...", []),
    Tab_Name = aurafs_mw_account_cache:init(),
    ?I("Account cache module started with reg name: ~p", [Tab_Name]),
    ?I("Starting main supervisor...", []),
    {ok, Sup_Pid} = aurafs_mw_sup:start_link(),
    ?I("Main supervisor started with pid: ~p", [Sup_Pid]),
    {ok, Sup_Pid}.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
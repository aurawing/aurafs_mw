%%%-------------------------------------------------------------------
%% @doc aurafs_mw public API
%% @end
%%%-------------------------------------------------------------------

-module(aurafs_mw_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-define(MONGO_POOL, mongo_pool).
-define(MONGO_REG, mongo_reg).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    {ok, Conf} = application:get_env(aurafs_mw),
    {topology, Topology} = lists:keyfind(topology, 1, Conf),
    {database, Database} = lists:keyfind(database, 1, Conf),
    {ok, _Topology} = mongoc:connect( Topology, [{name, ?MONGO_POOL}, {register, ?MONGO_REG}], [{database, Database}] ).

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

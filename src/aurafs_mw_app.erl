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
    {options, Options} = lists:keyfind(options, 1, Conf),
    {worker_options, Worker_Options} = lists:keyfind(worker_options, 1, Conf),
    Options2 = lists:keystore(register, 1, Options, {name, ?MONGO_POOL}),
    Options3 = lists:keystore(register, 1, Options2, {name, ?MONGO_REG}),
    {ok, _Topology} = mongoc:connect( Topology, Options3, Worker_Options).

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

%%%-------------------------------------------------------------------
%% @doc aurafs_mw top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(aurafs_mw_sup).

-behaviour(supervisor).

-include("../include/log.hrl").

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
-define(MONGO_POOL, mongo_pool).
-define(MONGO_REG, mongo_reg).
-define(CHILD_SPEC(Module, Args, Restart, MaxTime, Type), {Module, {Module, start_link, Args}, Restart, MaxTime, Type, [Module]}).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, Conf} = application:get_env(aurafs_mw),
    {topology, Topology} = lists:keyfind(topology, 1, Conf),
    {options, Options} = lists:keyfind(options, 1, Conf),
    {worker_options, Worker_Options} = lists:keyfind(worker_options, 1, Conf),
    Options2 = lists:keystore(register, 1, Options, {name, ?MONGO_POOL}),
    Options3 = lists:keystore(register, 1, Options2, {register, ?MONGO_REG}),
    SPEC1 = ?CHILD_SPEC(mc_pool_sup, [], permanent, 2000, supervisor),
    SPEC2 = ?CHILD_SPEC(mc_topology, [Topology, Options3, Worker_Options], permanent, 2000, worker),
    {ok, { {one_for_one, 0, 1}, [
        SPEC1,
        SPEC2
    ]} }.

%%====================================================================
%% Internal functions
%%====================================================================

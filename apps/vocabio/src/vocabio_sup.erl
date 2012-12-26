-module(vocabio_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    PoolArgs = [
                {size, 10},
                {max_overflow, 20},
                {name, {local, vbo_db_riak}},
                {worker_module, poolboy_riakc_worker}
               ],
    WorkerArgs = [
                  {hostname, "127.0.0.1"},
                  {port, 8087}
                 ],
    PoolChildSpec = poolboy:child_spec(vbo_db_riak, PoolArgs, WorkerArgs),
    Children = [PoolChildSpec,
                {cowboy_session_sup,
                 {cowboy_session_sup, start_link, [vbo_session_handler]},
                 permanent, 5000, supervisor, []}
               ],
    {ok, { {one_for_one, 5, 10}, Children} }.

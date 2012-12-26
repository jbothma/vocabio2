-module(poolboy_riakc_worker).

-export([start_link/1]).

start_link(Args) ->
    {_, Host} = lists:keyfind(hostname, 1, Args),
    {_, Port} = lists:keyfind(port, 1, Args),
    riakc_pb_socket:start_link(Host, Port).

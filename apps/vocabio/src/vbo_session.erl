-module(vbo_session).

-export([
         set/3
         ,get/2
        ]).

set(SessionHandle, Key, Value) ->
    ok = cowboy_session_server:command(SessionHandle, {set, {Key, Value}}).

get(SessionHandle, Key) ->
    cowboy_session_server:command(SessionHandle, {get, Key}).

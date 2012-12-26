-module(vbo_session_handler).
-extends(cowboy_session_default_handler).
-export([
         validate/1
         ,init/2
         ,handle/3
        ]).

-record(session_state,
        {
          data = []
        }).

validate(_Session) ->
   ?MODULE:generate().

init(_Session, _SessionName) ->
    #session_state{}.

handle({set, {Key, Value}}, _Session, State) ->
    Data = lists:keystore(Key, 1, State#session_state.data, {Key, Value}),
    {ok, State#session_state{ data = Data }};
handle({get, Key}, _Session, State) ->
    RetValue =
        case lists:keyfind(Key, 1, State#session_state.data) of
            {_, Value} ->
                {ok, Value};
            _ ->
                {ok, notfound}
        end,
    {RetValue, State}.

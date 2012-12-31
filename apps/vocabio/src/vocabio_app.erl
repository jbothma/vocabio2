-module(vocabio_app).

-behaviour(application).

%% Application callbacks
-export([
         start/0
         ,start/2
         ,stop/1
        ]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    {ok, _} = reloader:start(),
    ok = application:start(compiler),
    ok = application:start(syntax_tools),
    ok = application:start(lager),
    ok = application:start(sasl),
    ok = application:start(crypto),
    ok = application:start(public_key),
    ok = application:start(inets),
    ok = application:start(ssl),
    ok = application:start(cowboy),
    ok = application:start(gproc),
    ok = application:start(ossp_uuid),
    ok = application:start(esupervisor),
    ok = application:start(poolboy),
    ok = application:start(vocabio),
    ok.

start(_StartType, _StartArgs) ->
    Dispatch = [
                 %% {Host, list({Path, Handler, Opts})}
                {'_', [ {[<<"auth">>, <<"openid">>, '...'], res_auth, []}
                       ,{[<<"user">>], res_user, []}
                       ,{[<<"user">>, userid], res_user_userid, []}
                       ,{[<<"user">>, userid, <<"word">>], res_user_userid_word, []}
                      ]}
               ],
    %% Name, NbAcceptors, Transport, TransOpts, Protocol, ProtoOpts
    cowboy:start_listener(my_http_listener, 100,
                          cowboy_tcp_transport, [{port, 8080}],
                          cowboy_http_protocol, [{dispatch, Dispatch},
                                                 {onrequest, fun cowboy_session:on_request/1}]
                         ),
    vocabio_sup:start_link().

stop(_State) ->
    ok.

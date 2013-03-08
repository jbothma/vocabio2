-module(vocabio_app).

-behaviour(application).

%% Application callbacks
-export([
         start/0
         ,stop/0
         ,start/2
         ,stop/1
        ]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Dispatch =
        [
         %% {Host, list({Path, Handler, Opts})}
         {'_', [
                {[], res_home, []}
                ,{[<<"auth">>, <<"openid">>, '...'], res_auth_openid, []}
                ,{[<<"user">>], res_user, []}
                ,{[<<"user">>, userid], res_user_userid, []}
                ,{[<<"user">>, userid, <<"delete">>], res_user_userid_delete, []}
                ,{[<<"user">>, userid, <<"word">>], res_user_userid_word, []}
                ,{[<<"user">>, userid, <<"word">>, wordid, <<"delete">>],
                  res_user_userid_word_wordid_delete, []}
               ]}
        ],
    %% Name, NbAcceptors, Transport, TransOpts, Protocol, ProtoOpts
    cowboy:start_listener(vocabio_http_listener,
                          100,
                          cowboy_tcp_transport,
                          [{port, 8080}],
                          cowboy_http_protocol,
                          [{dispatch, Dispatch},
                           {onrequest, fun cowboy_session:on_request/1}]
                         ),
    vocabio_sup:start_link().

stop(_State) ->
    ok.

%% Development support
start() ->
    {ok, _} = reloader:start(),
    ok = application:load(vocabio),
    {ok, Apps} = application:get_key(vocabio, applications),
    true = lists:all(fun ensure_started/1, Apps ++ [vocabio]),
    ok.

stop() ->
    stopped = reloader:stop(),
    {ok, Apps} = application:get_key(vocabio, applications),
    true = lists:all(fun(kernel)  -> true;
                       (AppName) -> ensure_stopped(AppName)
                  end, Apps ++ [vocabio]),
    ok.

ensure_started(AppName) ->
    case {AppName, application:start(AppName)} of
        {AppName, ok} ->
            true;
        {AppName, {error, {already_started, AppName}}} ->
            true
    end.

ensure_stopped(AppName) ->
    case {AppName, application:stop(AppName)} of
        {AppName, ok} ->
            true
    end.

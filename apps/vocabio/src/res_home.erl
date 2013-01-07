-module(res_home).

-export([init/3, handle/2, terminate/2]).

init({tcp, http}, Req, _Opts) ->
    {ok, Req, undefined_state}.

handle(Req, State) ->
    {Path, Req1} = cowboy_http_req:path_info(Req),
    {Method, Req2} = cowboy_http_req:method(Req1),
    {Code, RespBody, Req3} = request(Method, Path, Req2),
    {ok, Req4} = cowboy_http_req:reply(Code, [], RespBody, Req3),
    {ok, Req4, State}.

request('GET', undefined, Req) ->
    request('GET', [], Req);
request('GET', [], Req) ->
    {Session, Req1} = cowboy_session:from_req(Req),
    ViewData =
        case vbo_session:get(Session, userid) of
            {ok, notfound} ->
                [];
            {ok, UserID} ->
                [{<<"userid">>, UserID}]
        end,
    {ok, IoData} = base_dtl:render(ViewData),
    {200, IoData, Req1}.

terminate(_Req, _State) ->
    ok.

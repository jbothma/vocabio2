-module(res_user_userid).

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
    {ok, UserID} = vbo_session:get(Session, user_id),
    %% for now just crash if the resource userid doesn't match the
    %% session userid to restrict access to the user resource
    {UserID, Req2} = cowboy_http_req:binding(userid, Req1),
    {ok, User} = vbo_model_user:get(UserID),
    ViewData = [{<<"user">>, User},
                {<<"userid">>, UserID}],
    {ok, IOData} = vbo_view_user_userid_dtl:render(ViewData),
    {200, IOData, Req2}.

terminate(_Req, _State) ->
    ok.

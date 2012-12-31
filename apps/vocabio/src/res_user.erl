-module(res_user).

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
    case vbo_session:get(Session, user_id) of
        {ok, notfound} ->
            {200, <<"User resources can be requested at /user/USERID">>, Req1};
        {ok, UserID} ->
            {200, [<<"your user resource is at /user/">>,UserID], Req1}
    end;
request('POST', undefined, Req) ->
    request('POST', [], Req);
request('POST', [], Req) ->
    {Session, Req1} = cowboy_session:from_req(Req),
    %% for now, just crash if they dont have an OpenID ID set.
    {ok, OpenIDIdentity} = vbo_session:get(Session, openid_identity),
    %% for now, just crash if they already have a user object. They shouldn't
    %% be posting this form and a better error response can be provided later.
    case vbo_model_user:get_id_by_openid(OpenIDIdentity) of
        {ok, notfound} ->
            {POSTVars, Req2} = cowboy_http_req:body_qs(Req1),
            {_, Nickname} = lists:keyfind(<<"nickname">>, 1, POSTVars),
            User = [{<<"nickname">>, Nickname}
                    ,{<<"openid_identity">>, OpenIDIdentity}],
            {ok, UID} = vbo_model_user:new(User),
            Location = [<<"/user/">>,UID],
            IOData = [<<"registered! now you can return to /auth/openid to "
                        "authenticate and your session id will grant you access"
                        " to your resources. The new resource is at ">>, Location],
            {ok, Req3} = cowboy_http_req:set_resp_header(<<"Location">>, Location, Req2),
            {201, IOData, Req3}
    end.

terminate(_Req, _State) ->
    ok.

-module(res_auth).
-export([init/3, handle/2, terminate/2]).

-define(RETURN_URL, "http://localhost:8080/auth/openid/return").

init({tcp, http}, Req, _Opts) ->
    {ok, Req, undefined_state}.

handle(Req, State) ->
    {Path, Req1} = cowboy_http_req:path_info(Req),
    {Method, Req2} = cowboy_http_req:method(Req1),
    {RespBody, Req3} = request(Method, Path, Req2),
    {ok, Req4} = cowboy_http_req:reply(200, [], RespBody, Req3),
    {ok, Req4, State}.

request(_Method, [], Req) ->
    GoogleOpenID = "https://www.google.com/accounts/o8/id",
    AuthReq = openid:discover(GoogleOpenID),
    Assoc = openid:associate(AuthReq),
    {Session, Req1} = cowboy_session:from_req(Req),
    ok = vbo_session:set(Session, openid_assoc, Assoc),
    Realm = "http://localhost:8080/",
    AuthURL = openid:authentication_url(AuthReq, ?RETURN_URL, Realm, Assoc),
    ViewData = [{<<"auth_url">>, AuthURL}],
    {ok, RespBody} = home_dtl:render(ViewData),
    {RespBody, Req1};

request(_Method, [<<"return">>], Req) ->
    {QueryStringPairs, Req1} = cowboy_http_req:qs_vals(Req),
    {Session, Req2} = cowboy_session:from_req(Req1),
    {ok, Assoc} = vbo_session:get(Session, openid_assoc),
    Bob = openid:verify(?RETURN_URL, Assoc, QueryStringPairs),
    {_, OpenIDIdentity} = lists:keyfind(<<"identity">>, 1, Bob),
    case vbo_model_user:get_id_by_openid(OpenIDIdentity) of
        {ok, notfound} ->
            ok = vbo_session:set(Session, openid_identity, OpenIDIdentity),
            {ok, Body} = register_dtl:render(),
            {Body, Req2};
        {ok, UserID} ->
            ok = vbo_session:set(Session, user_id, UserID),
            ViewData = [{<<"userid">>, UserID}],
            {ok, IOData} = base_dtl:render(ViewData),
            {IOData, Req2}
    end.


terminate(_Req, _State) ->
    ok.

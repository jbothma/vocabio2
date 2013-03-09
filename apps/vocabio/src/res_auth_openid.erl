-module(res_auth_openid).

-export([
         init/3
         ,allowed_methods/2
         ,content_types_provided/2
         ,to_text_html/2
         ,to_application_json/2
        ]).

-define(RETURN_URL(BaseURL), BaseURL++"auth/openid/return").

init(_Transport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_http_rest}.

allowed_methods(Req, State) ->
    {['GET'], Req, State}.

content_types_provided(Req, State) ->
    Callbacks =
        [
         {{<<"text">>, <<"html">>, []}, to_text_html}
         ,{{<<"application">>, <<"json">>, []}, to_application_json}
        ],
    {Callbacks, Req, State}.

to_text_html(Req, State) ->
    {ViewData, Req2, State1} =
        case cowboy_http_req:path_info(Req) of
            {[], Req1} ->
                get_start(Req1, State);
            {undefined, Req1} ->
                get_start(Req1, State);
            {[<<"return">>], Req1} ->
                get_return(Req1, State)
        end,
    {ok, RespBody} = view_auth_openid_dtl:render(ViewData),
    {RespBody, Req2, State1}.

to_application_json(Req, State) ->
    case cowboy_http_req:path_info(Req) of
        {[], Req1} ->
            {ViewData, Req2, State1} = get_start(Req1, State),
            {jsx:encode(ViewData), Req2, State1};
        {[<<"return">>], Req1} ->
            {ViewData, Req2, State1} = get_return(Req1, State),
            {jsx:encode(ViewData), Req2, State1}
    end.

get_start(Req, State) ->
    GoogleOpenID = "https://www.google.com/accounts/o8/id",
    AuthReq = openid:discover(GoogleOpenID),
    Assoc = openid:associate(AuthReq),
    {Session, Req1} = cowboy_session:from_req(Req),
    ok = vbo_session:set(Session, openid_assoc, Assoc),
    {ok, BaseURL} = application:get_env(vocabio, base_url),
    Realm = BaseURL,
    AuthURL =
        openid:authentication_url(AuthReq, ?RETURN_URL(BaseURL), Realm, Assoc),
    ViewData = [{<<"auth_url">>, list_to_binary(AuthURL)}],
    {ViewData, Req1, State}.

get_return(Req, State) ->
    {QueryStringPairs, Req1} = cowboy_http_req:qs_vals(Req),
    {Session, Req2} = cowboy_session:from_req(Req1),
    {ok, Assoc} = vbo_session:get(Session, openid_assoc),
    {ok, BaseURL} = application:get_env(vocabio, base_url),
    Bob = openid:verify(?RETURN_URL(BaseURL), Assoc, QueryStringPairs),
    {_, OpenIDIdentity} = lists:keyfind(<<"identity">>, 1, Bob),
    case vbo_model_user:get_id_by_openid(OpenIDIdentity) of
        {ok, notfound} ->
            ok = vbo_session:set(Session, openid_identity, OpenIDIdentity),
            ViewData = [{<<"openid_identity">>, OpenIDIdentity}],
            {ViewData, Req2, State};
        {ok, UserID} ->
            ok = vbo_session:set(Session, userid, UserID),
            ViewData = [{<<"userid">>, UserID}],
            {ViewData, Req2, State}
    end.

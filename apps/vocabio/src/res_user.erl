-module(res_user).

-export([
         init/3
         ,allowed_methods/2
         ,content_types_accepted/2
         ,content_types_provided/2
         ,is_authorized/2
         ,post_from_form/2
         ,to_text_html/2
         ,to_application_json/2
         ,post_is_create/2
         ,created_path/2
        ]).

init(_Transport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_http_rest}.

allowed_methods(Req, State) ->
    {['POST', 'GET'], Req, State}.

content_types_accepted(Req, State) ->
    Callbacks =
        [
         {{<<"application">>, <<"x-www-form-urlencoded">>, []}, post_from_form}
        ],
    {Callbacks, Req, State}.

content_types_provided(Req, State) ->
    Callbacks =
        [
         {{<<"text">>, <<"html">>, []}, to_text_html}
         ,{{<<"application">>, <<"json">>, []}, to_application_json}
        ],
    {Callbacks, Req, State}.

is_authorized(Req, State) ->
    case cowboy_http_req:method(Req) of
        {'POST', Req1} ->
            {Session, Req2} = cowboy_session:from_req(Req1),
            {ok, BaseURL} = application:get_env(vocabio, base_url),
            WWWAuthVal = ["OpenID ", BaseURL, "auth"],
            Body = ["Unauthorized. An OpenID identity should be authenticated via ",
                    BaseURL, "auth first. A new user can only be created by an OpenID"
                    " identity that is not associated with an existing user."],
            case vbo_session:get(Session, openid_identity) of
                {ok, notfound} ->
                    {ok, Req2} = cowboy_http_req:set_resp_body(Body, Req1),
                    {{false, WWWAuthVal}, Req2, State};
                {ok, OpenIDIdentity} ->
                    case vbo_model_user:get_id_by_openid(OpenIDIdentity) of
                        {ok, notfound} ->
                            {true, Req1, State};
                        _ ->
                            {ok, Req2} = cowboy_http_req:set_resp_body(Body, Req1),
                            {{false, WWWAuthVal}, Req2, State}
                    end
            end;
        {'GET', Req1} ->
            {true, Req1, State}
    end.

post_from_form(Req, _State) ->
    {Session, Req1} = cowboy_session:from_req(Req),
    {ok, OpenIDIdentity} = vbo_session:get(Session, openid_identity),
    {POSTVars, Req2} = cowboy_http_req:body_qs(Req1),
    {_, Nickname} = lists:keyfind(<<"nickname">>, 1, POSTVars),
    User = [{<<"nickname">>, Nickname}
            ,{<<"openid_identity">>, OpenIDIdentity}],
    {ok, UID} = vbo_model_user:new(User),
    {true, Req2, UID}.

to_text_html(Req, State) ->
    {Session, Req1} = cowboy_session:from_req(Req),
    {ok, UserID} = vbo_session:get(Session, userid),
    ViewData = [{<<"userid">>, UserID}],
    {ok, Body} = base_dtl:render(ViewData),
    {Body, Req1, State}.

to_application_json(Req, State) ->
    {Session, Req1} = cowboy_session:from_req(Req),
    {ok, UserID} = vbo_session:get(Session, userid),
    JSONTerm =
        [[{<<"uri">>, <<"/user/", UserID/binary>>}]],
    {JSONTerm, Req1, State}.

post_is_create(Req, State) ->
    {true, Req, State}.

created_path(Req, State = UID) ->
    Path = iolist_to_binary([<<"/user/">>, UID]),
    {Path, Req, State}.

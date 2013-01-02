-module(res_user_userid).

-export([
         init/3
         ,allowed_methods/2
         ,content_types_provided/2
         ,is_authorized/2
         ,to_text_html/2
        ]).

init(_Transport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_http_rest}.

allowed_methods(Req, State) ->
    {['GET'], Req, State}.

content_types_provided(Req, State) ->
    {[{{<<"text">>, <<"html">>, []}, to_text_html}], Req, State}.

is_authorized(Req, State) ->
    vbo_auth:is_authorized(Req, State).

to_text_html(Req1, State) ->
    {UserID, Req2} = cowboy_http_req:binding(userid, Req1),
    {ok, User} = vbo_model_user:get(UserID),
    ViewData = [{<<"user">>, User},
                {<<"userid">>, UserID}],
    {ok, IOData} = vbo_view_user_userid_dtl:render(ViewData),
    {IOData, Req2, State}.

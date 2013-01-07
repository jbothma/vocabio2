-module(res_user_userid_delete).

-export([
         init/3
         ,allowed_methods/2
         ,content_types_accepted/2
         ,content_types_provided/2
         ,is_authorized/2
         ,post_from_form/2
         ,to_text_html/2
         ,post_is_create/2
         ,create_path/2
        ]).

init(_Transport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_http_rest}.

allowed_methods(Req, State) ->
    {['POST'], Req, State}.

content_types_accepted(Req, State) ->
    Callbacks =
        [{{<<"application">>, <<"x-www-form-urlencoded">>, []}, post_from_form}],
    {Callbacks, Req, State}.

content_types_provided(Req, State) ->
    {[{{<<"text">>, <<"html">>, []}, to_text_html}], Req, State}.

is_authorized(Req, State) ->
    vbo_auth:is_authorized(Req, State).

post_from_form(Req, State) ->
    {UserID, Req1} = cowboy_http_req:binding(userid, Req),
    ok = vbo_model_user:delete(UserID),
    {true, Req1, State}.

to_text_html(Req, State) ->
    {[], Req, State}.

post_is_create(Req, State) ->
    {true, Req, State}.

create_path(Req, State) ->
    {<<"/user">>, Req, State}.

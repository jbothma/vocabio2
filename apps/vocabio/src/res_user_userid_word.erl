-module(res_user_userid_word).

-export([
         init/3
         ,allowed_methods/2
         ,content_types_accepted/2
         ,content_types_provided/2
         ,is_authorized/2
         ,post_from_form/2
         ,post_is_create/2
         ,to_text_html/2
         ,process_post/2
         ,created_path/2
        ]).

init(_Transport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_http_rest}.

allowed_methods(Req, State) ->
    {['POST', 'GET'], Req, State}.

content_types_accepted(Req, State) ->
    Callbacks =
        [{{<<"application">>, <<"x-www-form-urlencoded">>, []}, post_from_form}],
    {Callbacks, Req, State}.

content_types_provided(Req, State) ->
    {[{{<<"text">>, <<"html">>, []}, to_text_html}], Req, State}.

is_authorized(Req, State) ->
    vbo_auth:is_authorized(Req, State).

post_from_form(Req, State) ->
io:format("post_from_form\n"),
    {UserID, Req1} = cowboy_http_req:binding(userid, Req),
    {POSTVars, Req2} = cowboy_http_req:body_qs(Req1),
    {_, Word} = lists:keyfind(<<"word">>, 1, POSTVars),
    WordInData = [{<<"word">>, Word}, {<<"userid">>, UserID}],
    {ok, WordID} = vbo_model_user_words:add_word(UserID, WordInData),
    %% Set location header directly here because create_path is called before
    %% this function gets called.
    Location = filename:join([<<"/user">>,
                              UserID,
                              <<"word">>,
                              cowboy_http:urlencode(WordID)]),
    {ok, Req3} = cowboy_http_req:set_resp_header(<<"Location">>, Location, Req2),
    {true, Req3, State}.

to_text_html(Req1, State) ->
    {UserID, Req2} = cowboy_http_req:binding(userid, Req1),
    {ok, UserWords} = vbo_model_user_words:get(UserID),
    WordViewData = [{<<"user_words">>, UserWords},
                    {<<"userid">>, UserID}],
    {ok, IOData} = view_user_userid_word_dtl:render(WordViewData),
    {IOData, Req2, State}.

process_post(Req, State) ->
io:format("process_post\n"),
    %% This is sufficient while we just crash out if the post can't be
    %% processed.
    {true, Req, State}.

post_is_create(Req, State) ->
    io:format("post_is_create\n"),
    {true, Req, State}.

created_path(Req, State) ->
    {UserID, Req1} = cowboy_http_req:binding(userid, Req),
    Path = iolist_to_binary(["/user/", UserID, "/word"]),
    {Path, Req1, State}.

%% @doc A processing resource to allow the plain HTML interface to delete
%% in a sane way while HTML forms don't support the DELETE method.
%% Yes, I think this is a bit of a hack. Suggestions welcome.
%% @end
-module(res_user_userid_word_wordid_delete).

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
         ,process_post/2
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
    {WordID, Req2} = cowboy_http_req:binding(wordid, Req1),
    ok = vbo_model_user_words:delete_word(UserID, WordID),
    {true, Req2, State}.

to_text_html(Req, State) ->
    {[], Req, State}.

post_is_create(Req, State) ->
    {true, Req, State}.

%% @doc By giving the create path of the updated user words resource we
%% return a 303 See Other which means User Agent clients will go and fetch
%% and display the updated resource. Very nice.
create_path(Req, State) ->
    {UserID, Req1} = cowboy_http_req:binding(userid, Req),
    {filename:join(["/","user", UserID, "word"]), Req1, State}.

process_post(Req, State) ->
    %% This is sufficient while we just crash out if the post can't be
    %% processed.
    {true, Req, State}.

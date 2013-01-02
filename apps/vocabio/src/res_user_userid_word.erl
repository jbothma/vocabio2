-module(res_user_userid_word).

-export([init/3, handle/2, terminate/2]).

init({tcp, http}, Req, _Opts) ->
    {ok, Req, undefined_state}.

handle(Req, State) ->
    {Path, Req1} = cowboy_http_req:path_info(Req),
    {Method, Req2} = cowboy_http_req:method(Req1),
    {Code, RespBody, Req3} = request(Method, Path, Req2),
    {ok, Req4} = cowboy_http_req:reply(Code, [], RespBody, Req3),
    {ok, Req4, State}.

request('POST', undefined, Req) ->
    request('POST', [], Req);
request('POST', [], Req) ->
    {Session, Req1} = cowboy_session:from_req(Req),
    {ok, UserID} = vbo_session:get(Session, user_id),
    %% for now just crash if the resource userid doesn't match the

    %% session userid to restrict access to the user resource
    {UserID, Req2} = cowboy_http_req:binding(userid, Req1),
    {POSTVars, Req3} = cowboy_http_req:body_qs(Req2),
    {_, Word} = lists:keyfind(<<"word">>, 1, POSTVars),
    WordInData = [{<<"word">>, Word}, {<<"userid">>, UserID}],
    {ok, WordID} = vbo_model_user_words:add_word(UserID, WordInData),
    Location = [<<"/user/">>, UserID, <<"/word/">>, cowboy_http:urlencode(WordID)],
    {ok, Req4} = cowboy_http_req:set_resp_header(<<"Location">>, Location, Req3),
    {ok, UserWords} = vbo_model_user_words:get(UserID),
    WordViewData = [{<<"user_words">>, UserWords},
                    {<<"userid">>, UserID}],
    {ok, IOData} = view_user_userid_word_dtl:render(WordViewData),
    {201, IOData, Req4};
request('GET', undefined, Req) ->
    request('GET', [], Req);
request('GET', [], Req) ->
    {Session, Req1} = cowboy_session:from_req(Req),
    {ok, UserID} = vbo_session:get(Session, user_id),
    %% for now just crash if the resource userid doesn't match the
    %% session userid to restrict access to the user resource
    {UserID, Req2} = cowboy_http_req:binding(userid, Req1),
    {ok, UserWords} = vbo_model_user_words:get(UserID),
    WordViewData = [{<<"user_words">>, UserWords},
                    {<<"userid">>, UserID}],
    {ok, IOData} = view_user_userid_word_dtl:render(WordViewData),
    {200, IOData, Req2}.


terminate(_Req, _State) ->
    ok.

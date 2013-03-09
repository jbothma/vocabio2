%%%-------------------------------------------------------------------
%%% @doc Test the vocabio API
%%% @end
%%%-------------------------------------------------------------------
-module(api_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").

suite() ->
    [{timetrap,{seconds,30}}].

init_per_suite(Config0) ->
    Config1 =
        [ {base_url, "http://localhost:8080/"}
        | Config0 ],
    ok = application:start(inets),
    ok = httpc:set_options([{cookies, enabled}]),
    ok = mock_openid:start(),
    ok = application:set_env(vocabio, base_url, ?config(base_url, Config1)),
    ok = vocabio_app:start(),
    Config1.

end_per_suite(_Config) ->
    ok = mock_openid:stop(),
    ok = vocabio_app:stop(),
    ok.

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, _Config) ->
    ok.

init_per_testcase(_TestCase, Config) ->
    Config.

end_per_testcase(_TestCase, _Config) ->
    ok.

all() ->
    [my_test_case].

my_test_case(Config) ->
    URL = ?config(base_url, Config) ++ "auth/openid",
    {StatusCode, RespHeads, RespBody} = request(URL),
    ct:pal("~p~n~p~n~p~n",[StatusCode, RespHeads, RespBody]),
    BodyJSON = jsx:decode(RespBody),

    AuthURL = proplists:get_value(<<"auth_url">>, BodyJSON),

    {StatusCode2, RespHeads2, RespBody2} = request(binary_to_list(AuthURL)),
    ct:pal("~p~n~p~n~s~n",[StatusCode2, RespHeads2, RespBody2]),
    ok.

%% @doc HTTP requests with Accept header as application/json
request(URL) ->
    request(get, URL, undefined, undefined).

request(Method, URL, ContentType, ReqBody) ->
    Request =
        case Method of
            get ->
                {URL, [{"Accept","application/json"}]};
            post ->
                {URL, [{"Accept","application/json"}], ContentType, ReqBody}
        end,
    {ok, {{_, StatusCode, _}, RespHeads, RespBody}} =
         httpc:request(Method, Request, [], [{body_format, binary}]),
    {StatusCode, RespHeads, RespBody}.

-module(vbo_auth).

-export([
         is_authorized/2
        ]).

is_authorized(Req, State) ->
    {Session, Req1} = cowboy_session:from_req(Req),
    {ok, UserID} = vbo_session:get(Session, userid),
    case cowboy_http_req:binding(userid, Req1) of
        {UserID, Req2} ->
            {true, Req2, State};
        _ ->
            {ok, BaseURL} = application:get_env(vocabio, base_url),
            WWWAuthVal = ["OpenID ", BaseURL, "auth"],
            ViewData = [<<"base_url">>, BaseURL],
            {ok, Body} = '401_dtl':render(ViewData),
            {ok, Req2} = cowboy_http_req:set_resp_body(Body, Req1),
            {{false, WWWAuthVal}, Req2, State}
    end.

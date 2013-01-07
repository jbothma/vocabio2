-module(vbo_model_user).

-export([
         new/1
         ,get/1
         ,get_id_by_openid/1
         ,delete/1
        ]).

new(UserProplist) ->
    {ok, UKey} = vbo_db:new(<<"user">>, UserProplist),
    %% Assume for the moment that there will be an openid id
    {_, OpenIDIdentity} = lists:keyfind(<<"openid_identity">>, 1, UserProplist),
    OpenIDUser = [{<<"user_key">>, UKey}],
    ok = vbo_db:put(<<"openid_identity_user">>, OpenIDIdentity, OpenIDUser),
    UserOpenIDID = [{<<"openid_identity">>, OpenIDIdentity}],
    ok = vbo_db:put(<<"user_openid_identity">>, UKey, UserOpenIDID),
    {ok, UKey}.

get(UserID) ->
    case vbo_db:get(<<"user">>, UserID) of
        {ok, notfound} ->
            {ok, notfound};
        {ok, User} ->
            {ok, User}
    end.

get_id_by_openid(OpenIDIdentity) ->
    %% TODO: This is an opportunity to use links in riak to immediately
    %% get the user if the mapping exists
    case vbo_db:get(<<"openid_identity_user">>, OpenIDIdentity) of
        {ok, notfound} ->
            {ok, notfound};
        {ok, [{<<"user_key">>, UKey}]} ->
            {ok, UKey}
    end.

delete(UserID) ->
    ok = vbo_model_user_words:delete(UserID),
    {ok, [{<<"openid_identity">>, OpenIDIdentity}]} =
        vbo_db:get(<<"user_openid_identity">>, UserID),
    ok = vbo_db:delete(<<"user_openid_identity">>, UserID),
    ok = vbo_db:delete(<<"openid_identity_user">>, OpenIDIdentity),
    ok = vbo_db:delete(<<"user">>, UserID).

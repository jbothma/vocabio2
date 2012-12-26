-module(vbo_model_user).

-export([
         new/1
         ,get/1
         ,get_id_by_openid/1
        ]).

new(UserProplist) ->
    {ok, UKey} = vbo_db:new(<<"user">>, UserProplist),
    %% Assume for the moment that there will be an openid id
    {_, OpenIDIdentity} = lists:keyfind(<<"openid_identity">>, 1, UserProplist),
    OpenIDUser = [{<<"user_key">>, UKey}],
    ok = vbo_db:put(<<"openid_identity_user">>, OpenIDIdentity, OpenIDUser),
    {ok, UKey}.

get(UserID) ->
    case vbo_db:get(<<"user">>, UserID) of
        {ok, notfound} ->
            {ok, notfound};
        {ok, User} ->
            {ok, User}
    end.

get_id_by_openid(OpenIDIdentity) ->
    %% This is an opportunity to use links in riak to immediately
    %% get the user if the mapping exists
    case vbo_db:get(<<"openid_identity_user">>, OpenIDIdentity) of
        {ok, notfound} ->
            {ok, notfound};
        {ok, [{<<"user_key">>, UKey}]} ->
            {ok, UKey}
    end.

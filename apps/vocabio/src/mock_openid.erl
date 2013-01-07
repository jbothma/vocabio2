-module(mock_openid).

-export([
         start/0,
         stop/0
        ]).

start() ->
    ok = meck:new(openid, [no_link]),
    ok = meck:expect(openid, discover,
                     fun(_IdentityStringBin) ->
                             mock_openid_auth_req
                     end),
    ok = meck:expect(openid, associate,
                     fun(mock_openid_auth_req) ->
                             mock_openid_association
                     end),
    ok = meck:expect(openid, authentication_url,
                     fun(mock_openid_auth_req,
                         ReturnURL, _Realm,
                         mock_openid_association) ->
                             ReturnURL
                     end),
    ok = meck:expect(openid, verify,
                     fun(_ReturnURL, mock_openid_association,
                         _QueryStringProplist) ->
                             [{<<"identity">>, <<"http://mock.openid/identity">>}]
                     end).

stop() ->
    meck:unload(openid).

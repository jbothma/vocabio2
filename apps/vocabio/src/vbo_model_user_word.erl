-module(vbo_model_user_word).

-export([
         new/1
         ,get/2
        ]).

-define(KEY(UserID, WordID),
        <<UserID/binary,"-", WordID/binary>>).

new(WordData) ->
    {_, UserID} = lists:keyfind(<<"userid">>, 1, WordData),
    {_, Word} = lists:keyfind(<<"word">>, 1, WordData),
    NormalizedWord = vbo_unicode:normalize(nfc, Word),
    Key = ?KEY(UserID, NormalizedWord),
    ok = vbo_db:put(<<"user_word">>, Key, [{<<"word">>, NormalizedWord}]),
    {ok, NormalizedWord}.

get(UserID, Word) ->
    NormalizedWord = vbo_unicode:normalize(nfc, Word),
    Key = ?KEY(UserID, NormalizedWord),
    vbo_db:get(<<"user_word">>, Key).

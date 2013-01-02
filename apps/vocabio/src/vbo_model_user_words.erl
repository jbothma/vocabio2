-module(vbo_model_user_words).

-export([
         add_word/2
         ,delete_word/2
         ,get/1
        ]).

-define(WORD_URI(UserID, WordID),
        <<"/user/",UserID/binary,"/word/",WordID/binary>>).

new(UserID) ->
    ok = vbo_db:put(<<"user_words">>, UserID, []).

add_word(UserID, WordData) ->
    UserWords1 = case vbo_db:get(<<"user_words">>, UserID) of
                    {ok, notfound} ->
                         ok = new(UserID),
                         {ok, UserWords} = vbo_db:get(<<"user_words">>, UserID),
                         UserWords;
                    {ok, UserWords} ->
                         UserWords
                 end,
    {_, Word} = lists:keyfind(<<"word">>, 1, WordData),
    {UserWords2, Word2} =
        case vbo_model_user_word:get(UserID, Word) of
            {ok, notfound} ->
                {ok, Word1} = vbo_model_user_word:new(WordData),
                {[Word1 | UserWords1], Word1};
            {ok, [{<<"word">>, Word1}]} ->
                {UserWords1, Word1}
        end,
    ok = vbo_db:put(<<"user_words">>, UserID, UserWords2),
    {ok, Word2}.

delete_word(UserID, Word) ->
    {ok, UserWords} = vbo_db:get(<<"user_words">>, UserID),
    {ok, Word1} = vbo_model_user_word:delete(UserID, Word),
    %% Delete the normalized utf8 form returned by vbo_model_user_word
    UserWords1 = lists:delete(Word1, UserWords),
    ok = vbo_db:put(<<"user_words">>, UserID, UserWords1).

get(UserID) ->
    case vbo_db:get(<<"user_words">>, UserID) of
        {ok, notfound} ->
            ok = new(UserID),
            vbo_db:get(<<"user_words">>, UserID);
        {ok, UserWords} ->
            {ok, UserWords}
    end.

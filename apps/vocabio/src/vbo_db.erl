-module(vbo_db).

-export([
         new/2
         ,put/3
         ,get/2
         ,delete/2
        ]).

new(Bucket, Proplist) ->
    Worker = poolboy:checkout(vbo_db_riak),
    ValJSON = jsx:encode(Proplist),
    Obj = riakc_obj:new(Bucket, undefined, ValJSON),
    {ok, Obj2} = riakc_pb_socket:put(Worker, Obj),
    Key = riakc_obj:key(Obj2),
    poolboy:checkin(vbo_db_riak, Worker),
    {ok, Key}.

put(Bucket, Key, Proplist) ->
    Worker = poolboy:checkout(vbo_db_riak),
    ValJSON = jsx:encode(Proplist),
    Obj2 = case riakc_pb_socket:get(Worker, Bucket, Key) of
              {error, notfound} ->
                  riakc_obj:new(Bucket, Key, ValJSON);
              {ok, Obj1} ->
                  riakc_obj:update_value(Obj1, ValJSON)
           end,
    ok = riakc_pb_socket:put(Worker, Obj2),
    poolboy:checkin(vbo_db_riak, Worker),
    ok.

get(Bucket, Key) ->
    Worker = poolboy:checkout(vbo_db_riak),
    Result = case riakc_pb_socket:get(Worker, Bucket, Key) of
                 {ok, Obj} ->
                     ValJSON = riakc_obj:get_value(Obj),
                     Val = jsx:decode(ValJSON),
                     {ok, Val};
                 {error, notfound} ->
                     {ok, notfound}
             end,
    poolboy:checkin(vbo_db_riak, Worker),
    Result.

delete(Bucket, Key) ->
    Worker = poolboy:checkout(vbo_db_riak),
    Result = riakc_pb_socket:delete(Worker, Bucket, Key),
    poolboy:checkin(vbo_db_riak, Worker),
    Result.

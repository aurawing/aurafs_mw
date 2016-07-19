%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 七月 2016 下午10:13
%%%-------------------------------------------------------------------
-module(aurafs_mw_file).
-author("aurawing").

-define(FILE_TBL, <<"file">>).

-define(D, <<"d">>).
-define(F, <<"f">>).

%% API
-export([create_dir/8]).

-export_type([file/0]).

-type file() :: #{ FileId :: binary() => {binary()},    % {"_id" : ObjectId("XXXXXX"),
                   Type :: binary() => binary(),        %  "type" : "f",
                   Owner :: binary() => binary(),       %  "owner" : "6a6878a878d89f898...",
                   Name :: binary() => binary(),        %  "name" : "testfile.txt",
                   Pid :: binary() => binary(),         %  "pid" : "556a768d8a6c6db7634cb3",
                   Apid :: binary() => [binary()],      %  "apid" : ["556a768d8a6c6db7634cb3","a7bc7878d878a87f813512",...],
                   Identity :: binary() => binary(),    %  "identity" : "7a987c8a87fb7987d8ae8979789a8126388a6786",
                   Maxver :: binary() => pos_integer(), %  "maxver" : 1,
                   Versions :: binary() => [version()], %  "versions" : [{"verno":1,...},...],
                   Ext :: binary() => map() }.          %  "ext"={"X1":"Y1","X2","Y2",...} }

-type version() :: #{ VerNo :: binary() => pos_integer(),             % {"verno" : 1,
                      Fd :: binary() => binary(),                     %  "fd" : "d7189898cb09a87182...",
                      CreateTime :: binary() => aurafs_mw:unixtime(), %  "create_time" : new Date(),
                      ModifyTime :: binary() => aurafs_mw:unixtime(), %  "modify_time" : new Date(),
                      InsertTime :: binary() => aurafs_mw:unixtime(), %  "insert_time" : new Date(),
                      Size :: binary() => non_neg_integer(),          %  "size" => 17625429,
                      Digest :: binary() => binary(),                 %  "digest" => "7868a7687a68a867868767c68768df768768...",
                      Curver :: binary() => boolean(),                %  "curver" => true,
                      Ext :: binary() => map() }.                     %  "ext"={"X1":"Y1","X2","Y2",...} }
file(Type, Owner, Name, Pid, Apid, Identity, Maxver, VerNo, Fd, CreateTime, ModifyTime, InsertTime, Size, Digest, Curver, Ext_g, Ext_v) ->
  #{<<"type">> => Type,
    <<"owner">> => Owner,
    <<"name">> => Name,
    <<"pid">> => Pid,
    <<"apid">> => Apid,
    <<"identity">> => Identity,
    <<"maxver">> => Maxver,
    <<"ext">> => Ext_g,
    <<"versions">> => [
      #{<<"verno">> => VerNo,
        <<"fd">> => Fd,
        <<"create_time">> => CreateTime,
        <<"modify_time">> => ModifyTime,
        <<"insert_time">> => InsertTime,
        <<"size">> => Size,
        <<"digest">> => Digest,
        <<"curver">> => Curver,
        <<"ext">> => Ext_v}
    ]
  }.

create_dir(Token, Owner, Name, Pid, Apid, CreateTime, ModifyTime, Ext) ->
  case aurafs_mw_account:is_super_user(Token) of
    true ->
      save_dir(<<"d">>, Owner, Name, <<"1">>, [<<"1">>], aurafs_mw_digest:sha1(<<$d, $|, Name/binary, $|, $1>>), 1, 1, <<"">>, os:timestamp(), os:timestamp(), os:timestamp(), 0, <<"">>, true, Ext, #{});
    false ->
      if
        Token /= Owner -> {error, unauthorized};
        true ->
          case aurafs_mw_account_cache:get(Token) of
            {error, _Reason} -> {error, unauthorized};
            {ok, _Account} ->
              save_dir(<<"d">>, Owner, Name, Pid, Apid, aurafs_mw_digest:sha1(<<$d, $|, Name/binary, $|, Pid/binary>>), 1, 1, <<"">>, CreateTime, ModifyTime, os:timestamp(), 0, <<"">>, true, Ext, #{})
          end
      end
  end.

save_dir(Type, Owner, Name, Pid, Apid, Identity, Maxver, Verno, Fd, CreateTime, ModifyTime, InsertTime, Size, Digest, Curver, Ext_g, Ext_v) ->
  Dir = file(Type, Owner, Name, Pid, Apid, Identity, Maxver, Verno, Fd, CreateTime, ModifyTime, InsertTime, Size, Digest, Curver, Ext_g, Ext_v),
  {{true, Status}, Dir1} = mongoc:transaction(mongo_reg,
    fun(Worker) ->
      mc_worker_api:insert(Worker, ?FILE_TBL, Dir)
    end),
  case maps:is_key(<<"writeErrors">>, Status) of
    true -> {error, insert_failed, hd(maps:get(<<"writeErrors">>, Status))};
    false -> {ok, Dir1}
  end.







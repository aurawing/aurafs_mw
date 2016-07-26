%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% 文件和文件夹操作相关功能
%%% @end
%%% Created : 12. 七月 2016 下午10:13
%%%-------------------------------------------------------------------
-module(aurafs_mw_file).
-author("aurawing").

-include("../include/file.hrl").
-include("../include/errors.hrl").
-include("../include/log.hrl").

%% API
-export([create_dir/6, get_file_by_id/1]).

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
  #{?F_TYPE => Type,
    ?F_OWNER => Owner,
    ?F_NAME => Name,
    ?F_PID => Pid,
    ?F_APID => Apid,
    ?F_IDENTITY => Identity,
    ?F_MAXVER => Maxver,
    ?F_EXT_G => Ext_g,
    ?F_VERSIONS => [
      #{?F_VERNO => VerNo,
        ?F_FD => Fd,
        ?F_CREATE_TIME => CreateTime,
        ?F_MODIFY_TIME => ModifyTime,
        ?F_INSERT_TIME => InsertTime,
        ?F_SIZE => Size,
        ?F_DIGEST => Digest,
        ?F_CURVER => Curver,
        ?F_EXT_V => Ext_v}
    ]
  }.

%%% @doc
%%% 创建文件夹
%%% @end
-spec create_dir(binary(), binary(), binary(), aurafs_mw:unixtime(), aurafs_mw:unixtime(), map()) -> {ok, file()} | aurafs_mw:unauthorized() | aurafs_mw:insert_failed(tuple()).
create_dir(Token, Name, Pid, CreateTime, ModifyTime, Ext_g) ->
  case aurafs_mw_account:is_super_user(Token) of
    true ->
      save_dir(?FTYPE_D, Token, Name, ?ROOT_DIR_ID, [?ROOT_DIR_ID], ?CREATE_IDENTITY(?FTYPE_D, Name, ?ROOT_DIR_ID), 1, 1, null, os:timestamp(), os:timestamp(), os:timestamp(), 0, null, true, Ext_g, #{});
    false ->
      case aurafs_mw_account_cache:get(Token) of
        {error, _Reason} -> ?UNAUTHORIZED;
        {ok, _Account} ->
          case check_pid(Pid, Token) of
            {true, #{?F_APID := Apid}} -> save_dir(?FTYPE_D, Token, Name, Pid, lists:reverse([Pid|lists:reverse(Apid)]), ?CREATE_IDENTITY(?FTYPE_D, Name, Pid), 1, 1, null, CreateTime, ModifyTime, os:timestamp(), 0, null, true, Ext_g, #{});
            false -> ?DIR_ACCESS_DENIED;
            no_folder -> ?NO_DIR
          end
      end
  end.

%%% @doc
%%% 根据id获取文件信息
%%% @end
-spec get_file_by_id(binary()) -> file() | #{}.
get_file_by_id(Id) ->
  mongoc:transaction_query(mongo_reg,
    fun(Conf) ->
      mongoc:find_one(Conf, ?FILE_TBL, #{?F_ID => Id}, #{}, 0)
    end).

check_pid(Pid, Owner) ->
  Dir = get_file_by_id(Pid),
  check_pid1(Dir, Owner).

check_pid1(#{}, _) -> no_folder;
check_pid1(Dir, Owner) ->
  case maps:find(?F_OWNER, Dir) of
    {ok, Owner} -> {true, Dir};
    error -> false
  end.

save_dir(Type, Owner, Name, Pid, Apid, Identity, Maxver, Verno, Fd, CreateTime, ModifyTime, InsertTime, Size, Digest, Curver, Ext_g, Ext_v) ->
  Dir = file(Type, Owner, Name, Pid, Apid, Identity, Maxver, Verno, Fd, CreateTime, ModifyTime, InsertTime, Size, Digest, Curver, Ext_g, Ext_v),
  {{true, Status}, Dir1} = mongoc:transaction(mongo_reg,
    fun(Worker) ->
      mc_worker_api:insert(Worker, ?FILE_TBL, Dir)
    end),
  case maps:is_key(<<"writeErrors">>, Status) of
    true -> ?INSERT_FAILED(hd(maps:get(<<"writeErrors">>, Status)));
    false -> {ok, Dir1}
  end.

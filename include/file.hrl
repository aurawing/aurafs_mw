%%%-------------------------------------------------------------------
%%% @author aurawing
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 七月 2016 上午10:30
%%%-------------------------------------------------------------------
-author("aurawing").

-define(F_ID, <<"_id">>).
-define(F_TYPE, <<"type">>).
-define(F_OWNER, <<"owner">>).
-define(F_NAME, <<"name">>).
-define(F_PID, <<"pid">>).
-define(F_APID, <<"apid">>).
-define(F_IDENTITY, <<"identity">>).
-define(F_MAXVER, <<"maxver">>).
-define(F_EXT_G, <<"ext_g">>).
-define(F_VERSIONS, <<"versions">>).
-define(F_VERNO, <<"verno">>).
-define(F_FD, <<"fd">>).
-define(F_CREATE_TIME, <<"create_time">>).
-define(F_MODIFY_TIME, <<"modify_time">>).
-define(F_INSERT_TIME, <<"insert_time">>).
-define(F_SIZE, <<"size">>).
-define(F_DIGEST, <<"digest">>).
-define(F_CURVER, <<"curver">>).
-define(F_EXT_V, <<"ext_v">>).

-define(FILE_TBL, <<"file">>).

-define(FTYPE_D, <<"d">>).
-define(FTYPE_F, <<"f">>).

-define(ROOT_PID, <<"1">>).
-define(ROOT_DIR_ID, <<"1">>).

-define(CREATE_IDENTITY(Type, Name, Pid), aurafs_mw_digest:sha1(<<Type/binary, $|, Name/binary, $|, Pid/binary>>)).

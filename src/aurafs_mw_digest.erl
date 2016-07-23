%%%-------------------------------------------------------------------
%%% @author aurawing
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 六月 2016 上午10:22
%%%-------------------------------------------------------------------
-module(aurafs_mw_digest).
-author("aurawing").

-include("../include/log.hrl").

%% API
-export([hex/1, md5/1, sha1/1]).

hex(Bin) ->
  hex_map(Bin, fun(X) -> X end).

md5(Str) ->
  hex_map(Str, fun crypto:md5/1).

sha1(Str) ->
  hex_map(Str, fun crypto:sha/1).

hex_map(Str, Fun) ->
  << <<(binary:at(<<"0123456789abcdef">>, X))>> || <<X:4>> <= Fun(Str) >>.
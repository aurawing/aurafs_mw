%%%-------------------------------------------------------------------
%%% @author root
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 七月 2016 下午2:50
%%%-------------------------------------------------------------------
-author("aurawing").

-define(I(M), lager:info(M)).
-define(W(M), lager:warning(M)).
-define(N(M), lager:notice(M)).
-define(E(M), lager:error(M)).
-define(D(M), lager:debug(M)).

-define(I(M, A), lager:info(M, A)).
-define(W(M, A), lager:warning(M, A)).
-define(N(M, A), lager:notice(M, A)).
-define(E(M, A), lager:error(M, A)).
-define(D(M, A), lager:debug(M, A)).

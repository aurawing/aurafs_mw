%%%-------------------------------------------------------------------
%%% @author aurawing
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%% 定义各种错误类型
%%% @end
%%% Created : 21. 七月 2016 下午3:05
%%%-------------------------------------------------------------------

-define(LOGIN_FAILED, {error, login_failed}). %% 登录失败
-define(UNAUTHORIZED, {error, unauthorized}). %% 未授权的请求
-define(DIR_ACCESS_DENIED, {error, dir_access_denied}). %% 目录禁止访问
-define(FILE_ACCESS_DENIED, {error, file_access_denied}). %% 文件禁止访问
-define(NO_DIR, {error, no_dir}). %% 目录不存在
-define(NO_FILE, {error, no_file}). %% 文件不存在
-define(INSERT_FAILED(Msg), {error, insert_failed, Msg}). %% 数据库插入失败

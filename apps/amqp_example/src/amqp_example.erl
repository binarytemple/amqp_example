%%%-------------------------------------------------------------------
%%% @author b
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. Mar 2019 12:47
%%%-------------------------------------------------------------------
-module(amqp_example).
-author("b").

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-include_lib("amqp_client/include/amqp_client.hrl").

-record(state, {connection, channel}).

timeout_millseconds() -> 1500.

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================


init([]) ->
  {ok, Host} = application:get_env(amqp_example, rabbit_host),

  {ok, Connection} =
    amqp_connection:start(#amqp_params_network{host = Host}),
  {ok, Channel} = amqp_connection:open_channel(Connection),

  amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),

  {ok, #state{connection=Connection, channel = Channel}, timeout_millseconds()}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call(_Request, _From, State) ->
  {reply, ok, State}.



handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(timeout, State = #state{channel = Channel}) ->
  amqp_channel:cast(Channel,
    #'basic.publish'{
      exchange = <<"">>,
      routing_key = <<"hello">>},
    #amqp_msg{payload = <<"Hello World!">>}),
  io:format(" [x] Sent 'Hello World!'~n"),
  {noreply, State, timeout_millseconds()}.

%%handle_info(Msg, State) ->
%%  io:format(" Unexpected message : ~p ~n", [Msg]),
%%  {noreply, State, timeout_millseconds()}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, #state{connection = Connection,channel = Channel}) ->
  ok = amqp_channel:close(Channel),
  ok = amqp_connection:close(Connection),
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

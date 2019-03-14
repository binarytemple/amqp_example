%%%-------------------------------------------------------------------
%% @doc amqp_example top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(amqp_example_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->

    SupFlags = #{strategy => one_for_all, intensity => 1, period => 5},
    ChildSpecs = [#{id => amqp_example,
        start => {amqp_example, start_link, []},
        restart => permanent,
        shutdown => brutal_kill,
        type => worker,
        modules => [amqp_example]}],
    {ok, {SupFlags, ChildSpecs}}.


%%====================================================================
%% Internal functions
%%====================================================================

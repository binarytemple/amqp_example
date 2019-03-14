FROM bitwalker/alpine-erlang:latest as build_release

ADD https://s3.amazonaws.com/rebar3/rebar3 /bin/rebar3

RUN chmod a+x /bin/rebar3

COPY . .

RUN rebar3 as prod release

FROM alpine:latest 

COPY --from=0 /opt/app/_build/prod/rel/amqp_example /amqp_example
 
RUN apk update && apk add ncurses

ENV RABBIT_HOST="rabbit.amqp"

COPY config/startup.sh /bin/startup

RUN chmod a+x /bin/startup

ENTRYPOINT ["/bin/startup"]

CMD ["help"]

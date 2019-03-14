amqp_example
=====

An OTP application

Build
-----

    $ rebar3 compile


local 
-----

```
RABBIT_HOST=localhost  _build/default/rel/amqp_example/bin/amqp_example console
```

docker 
-----


One terminal...

```
docker network create amqp
docker run --rm --network amqp --hostname rabbit --name rabbit -p 5672:5672 -p 15672:15672 rabbitmq:3.7.7-management
```

Second terminal... 
```
docker build . -t amqp_example
docker run -ti --rm --network amqp --hostname ampq_example --name amqp_example -e RABBIT_HOST=rabbit amqp_example:latest
```

I just want a shell... 

```
docker run -ti --rm --network amqp --hostname ampq_example --name amqp_example -e RABBIT_HOST=rabbit.amqp --entrypoint /bin/sh amqp_example:latest
```


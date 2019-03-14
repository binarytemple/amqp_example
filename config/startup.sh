#!/bin/sh

echo ^c | nc $RABBIT_HOST 5672 > /dev/null || \
  (echo "Quitting - cannot connect to RABBIT_HOST=\"${RABBIT_HOST}\" " && exit 1)

exec /amqp_example/bin/amqp_example $@

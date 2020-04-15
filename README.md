## This is example how to implement pubsub to mql4 and run headless in docker.

Copy file `/mt4/startup.ini.dist` > `/mt4/startup.ini`, add your Login, Password and Server

then run

```
docker-compose up --build -d
```

Subscribe channel `Symbol-info` to listen information of a symbol. It fire whenever this container start or when publish channel `get-symbol-infor` with message is a symbol

Subscribe channel `tick` to listen market-depth of symbol define in `/mt4/startup.ini`

Subscribe channel `health` to listen is EA still alive. Fire 1 message per 300s

Log can read on `/mt4/logs` or `/mt4/MQL4/Files`

For more information, read 2 responsitories below:

- Pubsub for MQL4: https://github.com/dingmaotu/mql4-redis
- Docker for MQL4: https://github.com/nevmerzhitsky/headless-metatrader4

To test, can use typescript

```
import * as redis from 'redis';

const subcriber = redis.createClient({
  host: process.env.REDIS_HOST,
  port: +(process.env.REDIS_PORT || 6379),
});

subcriber.subscribe('Symbol-info');
subcriber.subscribe('tick');
subcriber.subscribe('health');

subcriber.on('message', (channel, message: string) => {
  console.log(channel, message);
});

// subcriber and publisher must be 2 individual object
const publisher = redis.createClient({
  host: process.env.REDIS_HOST,
  port: +(process.env.REDIS_PORT || 6379),
});

setTimeout(() => {
  publisher.publish('get-symbol-infor', 'EURUSD');
}, 10000);
```

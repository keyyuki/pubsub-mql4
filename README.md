Please read and config as 2 responsitories below:

- Pubsub for MQL4: https://github.com/dingmaotu/mql4-redis
- Docker for MQL4: https://github.com/nevmerzhitsky/headless-metatrader4

Create file `/mt4/config.ini` like that

```
REDIS_HOST=host.docker.internal
REDIS_POST=6379
```

then run

```
docker-compose up --build -d
```

Subscribe channel `Symbol-info` to listen information of a symbol. It fire whenever this container start or when publish channel `get-symbol-infor` with message is a symbol

Subscribe channel `tick` to listen market-depth of symbol define in `/mt4/startup.ini`

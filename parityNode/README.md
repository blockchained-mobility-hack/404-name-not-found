# Parity node

## Build docker
```
docker build --no-cache -t mobi-pay-node .
```
## Start node in docker
```
docker run -p 8545:8545 -p 8546:8546 mobi-pay-node
```
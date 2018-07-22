FROM parity/parity:v1.11.4

ADD spec spec

ADD spec/keys/ /root/.local/share/io.parity.ethereum/keys/MobiPayNode


EXPOSE 8545 8546

CMD ["--config", "spec/config.toml", "--unsafe-expose", "--ws-apis", "all", "--ws-origins", "all", "--ws-hosts", "all",  "--gasprice", "0", "--gas-floor-target", "20000000",  "--rpcapi", "all",  "--rpcaddr", "all", "--jsonrpc-hosts", "all"]
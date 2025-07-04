#!/bin/bash
set -x

# 获取 mykey 的地址
ADDR=$(docker exec ethermint-node ethermintd keys show mykey --keyring-backend test -a)
echo "ADDR=$ADDR"
echo "ADDR exit code: $?"
if [ $? -ne 0 ]; then
  echo "❌ 获取地址失败，请确认 ethermint-node 容器和 mykey 存在。"
  exit 1
fi

# 导出 mykey 的私钥（hex）
PRIV=$(docker exec ethermint-node ethermintd keys export mykey --unarmored-hex --unsafe --keyring-backend test)
echo "PRIV=$PRIV"
echo "PRIV exit code: $?"
if [ $? -ne 0 ]; then
  echo "❌ 导出私钥失败，请确认 ethermint-node 容器和 mykey 存在。"
  exit 1
fi

# 写入 deployment/ethermint.txt
ETHERMINT_TXT=deployment/ethermint.txt
if [ ! -f "$ETHERMINT_TXT" ]; then
  touch "$ETHERMINT_TXT"
fi
echo -e "ethermint_address: $ADDR\nethermint_privkey: $PRIV" > "$ETHERMINT_TXT"

echo "✅ 已写入 ethermint_address 和 ethermint_privkey 到 $PARAMS_FILE"
set +x 
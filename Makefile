# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

#
#	--- Deployment Scripts ---
#

deploy-punksbids-mainnet:
	forge script script/DeployMainnet.s.sol:DeployMainnet --rpc-url ${MAINNET_RPC_URL} --broadcast --verify --chain-id 1 --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

deploy-punksbids-goerli:
	forge script script/DeployTestnet.s.sol:DeployGoerli --rpc-url ${GOERLI_RPC_URL} --broadcast -vvvv

#
#	--- Scripts TESTs ---
#

unit-tests:
	forge test --fork-url ${MAINNET_RPC_URL} -vvv

coverage:
	forge coverage --fork-url ${MAINNET_RPC_URL} -vvv

coverage-report:
	forge coverage --fork-url ${MAINNET_RPC_URL} -vvv --report lcov
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GasHive {
    struct QueuedTx {
        address sender;
        bytes data;
        uint256 gasTarget;
        bool executed;
    }

    uint256 public txCount;
    address public executor;
    mapping(uint256 => QueuedTx) public queue;

    event TxQueued(uint256 indexed id, address indexed sender, uint256 gasTarget);
    event TxExecuted(uint256 indexed id);

    modifier onlyExecutor() {
        require(msg.sender == executor, "Not executor");
        _;
    }

    constructor(address _executor) {
        executor = _executor;
    }

    function queueTransaction(bytes calldata data, uint256 gasTarget) external {
        queue[txCount] = QueuedTx({
            sender: msg.sender,
            data: data,
            gasTarget: gasTarget,
            executed: false
        });

        emit TxQueued(txCount, msg.sender, gasTarget);
        txCount++;
    }

    function executeTransaction(uint256 txId, address target) external onlyExecutor {
        QueuedTx storage txInfo = queue[txId];
        require(!txInfo.executed, "Already executed");

        (bool success, ) = target.call{gas: txInfo.gasTarget}(txInfo.data);
        require(success, "Tx failed");

        txInfo.executed = true;
        emit TxExecuted(txId);
    }

    function getTransaction(uint256 txId) external view returns (
        address sender, bytes memory data, uint256 gasTarget, bool executed
    ) {
        QueuedTx storage txInfo = queue[txId];
        return (txInfo.sender, txInfo.data, txInfo.gasTarget, txInfo.executed);
    }
}

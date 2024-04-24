// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
/**
 * @title A sample Raffle Contract
 * @author KENTO
 * @notice This contract is fro creating a smaple raffle
 * @dev Implements Chainlink VRFv2
 */

contract Raffle is VRFConsumerBaseV2 {
    error Raffle_NotEnoughFee_Error();
    error Raffle_Transfer_Error();
    error Raffle_NotOpen_Error();
    error Raffle_Upkeep_NotNeeded(uint256 balance, uint256 playersNum, uint256 state);

    enum RaffleState {
        CALCULATING, // 0
        OPEN // 1

    }

    uint16 private constant DEFAULT_REQUEST_CONFIRMATIONS = 3;
    uint32 private constant DEFAULT_NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    address payable private s_recentWinner;
    uint256 private s_lastTimestamp;
    RaffleState private s_raffleState;

    /**
     * Events
     */
    event RafflePlayerEnter(address indexed player);

    event RaffleWinnerPicker(address indexed winner, uint256 bonus);

    event RequestedRaffleWinner(uint256 indexed requestId);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimestamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle_NotEnoughFee_Error();
        }

        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle_NotOpen_Error();
        }

        s_players.push(payable(msg.sender));
        // 每当更新storage时，均需要发出事件
        emit RafflePlayerEnter(msg.sender);
    }

    /**
     * @dev 该方法由Chainlink Automation直接调用，判断是否达到临界状态调用perform an upkeep
     * 需要满足如下要求:
     * 1. Raffle需运行一段时间(interval)
     * 2. RaffleState需OPEN
     * 3. Raffle存在玩家且有余额
     * 4. ChanlinkSubscription is fund with LINK
     * @return upkeepNeeded
     */
    function checkUpkeep(bytes memory /* checkData */ )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        bool intervalPassed = block.timestamp - s_lastTimestamp >= i_interval;
        bool openStatePassed = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayer = s_players.length > 0;
        upkeepNeeded = intervalPassed && openStatePassed && hasBalance && hasPlayer;
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */ ) external {
        (bool upKeepNeeded,) = checkUpkeep("");
        if (!upKeepNeeded) {
            revert Raffle_Upkeep_NotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }

        s_raffleState = RaffleState.CALCULATING;
        // Generate Random Number
        // Use ChainLink VRF
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, i_subscriptionId, DEFAULT_REQUEST_CONFIRMATIONS, i_callbackGasLimit, DEFAULT_NUM_WORDS
        );

        emit RequestedRaffleWinner(requestId);
    }

    /**
     * @dev This function is called by Chainlink VNF Nodes
     */
    function fulfillRandomWords(uint256, uint256[] memory _randomWords) internal override {
        uint256 winnerIndex = _randomWords[0] % s_players.length;
        s_recentWinner = s_players[winnerIndex];
        s_players = new address payable[](0);
        s_raffleState = RaffleState.OPEN;
        s_lastTimestamp = block.timestamp;
        uint256 bonus = address(this).balance;
        (bool success,) = s_recentWinner.call{value: bonus}("");
        if (!success) {
            revert Raffle_Transfer_Error();
        }

        emit RaffleWinnerPicker(s_recentWinner, bonus);
    }

    /**
     * Getter Function
     */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) external view returns (address) {
        if (index >= s_players.length) {
            revert();
        }
        return s_players[index];
    }

    function getPlayerNum() external view returns (uint256) {
        return s_players.length;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }

    function getLastTimestamp() external view returns (uint256) {
        return s_lastTimestamp;
    }
}

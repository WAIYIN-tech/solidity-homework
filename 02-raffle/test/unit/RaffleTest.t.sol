// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {Vm} from "forge-std/Vm.sol";

contract RaffleTest is Test {
    address public PLAYER = makeAddr("KENTO");
    uint256 public INITIAL_BALANCE = 10 ether;

    Raffle private s_raffle;
    HelperConfig private helperConfig;

    uint256 private entranceFee;
    uint256 private interval;
    address private vrfCoordinator;
    bytes32 private gasLane;
    uint64 private subscriptionId;
    uint32 private callbackGasLimit;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (s_raffle, helperConfig) = deployRaffle.run();
        (entranceFee, interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit,,) =
            helperConfig.activeNetworkConfig();
        console.log("entranceFee ", entranceFee);
        console.log("Initial balance: ", INITIAL_BALANCE);
        vm.deal(PLAYER, INITIAL_BALANCE);
    }

    function testInitialRaffleState() public view {
        assert(s_raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testEnterRaffle() public {
        vm.expectEmit(true, false, false, false, address(s_raffle));
        emit Raffle.RafflePlayerEnter(PLAYER);

        vm.startPrank(PLAYER);
        s_raffle.enterRaffle{value: entranceFee}();
        vm.stopPrank();
        assertEq(s_raffle.getPlayer(0), PLAYER);
    }

    function testEnterRaffleNotEnoughFee() public {
        vm.expectRevert(Raffle.Raffle_NotEnoughFee_Error.selector);
        vm.prank(PLAYER);
        s_raffle.enterRaffle{value: (entranceFee - 0.0001 ether)}();
        assertEq(s_raffle.getPlayerNum(), 0);
    }

    modifier modifier_palyerEnter() {
        vm.startPrank(PLAYER);
        s_raffle.enterRaffle{value: entranceFee}();
        vm.stopPrank();
        assert(s_raffle.getPlayer(0) == PLAYER);
        _;
    }

    function testEnterRaffleGotNotOpenError() public modifier_palyerEnter {
        assert(s_raffle.getRaffleState() == Raffle.RaffleState.OPEN);

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        s_raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle_NotOpen_Error.selector);
        vm.startPrank(PLAYER);
        s_raffle.enterRaffle{value: entranceFee}();
        vm.stopPrank();
    }

    /**
     * checkUpKeep
     */
    function testCheckUpKeepReturnsFalseIfIthasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeed,) = s_raffle.checkUpkeep("");
        assert(!upkeepNeed);
    }

    function testCheckUpKeepReturnsFalseIfRaffleNotOpen() public {
        vm.prank(PLAYER);
        s_raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        s_raffle.performUpkeep("");

        (bool upkeepNeeded,) = s_raffle.checkUpkeep("");
        assert(upkeepNeeded == false);
    }

    function testCheckUpKeepReturnsFalseIfEnoughTimeHasntPassed() public modifier_palyerEnter {
        vm.warp(block.timestamp + interval - 1);
        vm.roll(block.number + 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle_Upkeep_NotNeeded.selector, address(s_raffle).balance, 1, uint256(Raffle.RaffleState.OPEN)
            )
        );
        s_raffle.performUpkeep("");
    }

    function testPerformUpKeepUpdatesRaffleStateAndEmitsRequestId() public modifier_palyerEnter {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        vm.recordLogs();
        s_raffle.performUpkeep("");

        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries[1].topics.length, 2);
        bytes32 requestId = entries[1].topics[1];

        Raffle.RaffleState rState = s_raffle.getRaffleState();

        assertEq(entries[1].topics[0], keccak256("RequestedRaffleWinner(uint256)"));
        assert(uint256(requestId) > 0);
        assert(rState == Raffle.RaffleState.CALCULATING);
    }

    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    /**
     * fulfillRandomWords
     */
    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpKeep(uint256 randomRequestId)
        public
        modifier_palyerEnter
        skipFork
    {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(s_raffle));
    }

    function testFulfillRandomWordsPicksAWinnerResetAndSendsMoney() public modifier_palyerEnter skipFork {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // Add Player
        uint256 additionEntrants = 5;
        uint256 startingIndex = 1;
        for (uint256 i = startingIndex; i < startingIndex + additionEntrants; i++) {
            address _player = address(uint160(i));
            hoax(_player, INITIAL_BALANCE);
            s_raffle.enterRaffle{value: entranceFee}();
        }

        // trigger VRF to getRandomWords
        vm.recordLogs();
        s_raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries[1].topics.length, 2);
        bytes32 requestId = entries[1].topics[1];
        assert(uint256(requestId) > 0);

        uint256 previousTimestamp = s_raffle.getLastTimestamp();
        uint256 prize = address(s_raffle).balance;
        // pretend VRF returns randomWords and pickWinner
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(s_raffle));

        assert(s_raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        assert(s_raffle.getPlayerNum() == 0);
        assert(s_raffle.getRecentWinner() != address(0));
        assert(previousTimestamp < s_raffle.getLastTimestamp());
        assertEq(s_raffle.getRecentWinner().balance, INITIAL_BALANCE + prize - entranceFee);
    }
}

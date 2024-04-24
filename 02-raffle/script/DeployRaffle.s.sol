// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {HelperConfig} from "./HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    uint256 public constant DEFAULT_ENTRACE_FEE = 5 ether;
    uint256 public constant DEFAULT_INTERVAL_OF_SECOND = 10;

    constructor() {}

    function run() external returns (Raffle, HelperConfig) {
        HelperConfig config = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey
        ) = config.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator, deployerKey);

            // TODO: FundIt
            FundSubscription _fundSubscription = new FundSubscription();
            _fundSubscription.fundSubscription(vrfCoordinator, subscriptionId, link, deployerKey);
        }

        vm.startBroadcast();
        Raffle _raffle = new Raffle(entranceFee, interval, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit);
        vm.stopBroadcast();

        /**
         * Refactor:AddConsumer(subscriptionId, address(Raffle))
         */
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(_raffle), vrfCoordinator, subscriptionId, deployerKey);

        return (_raffle, config);
    }
}

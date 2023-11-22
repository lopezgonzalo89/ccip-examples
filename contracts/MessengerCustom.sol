// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";

struct DappTransmissionInfo {
    bytes dappTransmissionSender;
    bytes dappTransmissionReceiver;
    bytes32 dAppId;
    bytes dappPayload;
}

/// @title - A simple messenger contract for sending/receving string data across chains.
contract MessengerCustom is CCIPReceiver, OwnerIsCreator {
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);
    error NothingToWithdraw();
    error FailedToWithdrawEth(address owner, address target, uint256 value);

    bytes32 private s_lastReceivedMessageId;
    bytes32[] private receivedMessageIds;

    IERC20 private s_linkToken;

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
    }

    function transmitErc20(
        uint64 _destinationChainSelector,
        address ccipTransmissionReceiver_,
        bytes calldata dappTransmissionReceiver_,
        bytes calldata receiver_
    ) external returns (bytes32 messageId) {
        DappTransmissionInfo memory dappTransmissionInfo = DappTransmissionInfo(
            abi.encodePacked(msg.sender),
            dappTransmissionReceiver_,
            0x72d39a1c0de7ff41e878b4d9fd3906d2fdc49e36188d0c595d57fb7dde21b1d8,
            abi.encode( // Payload
                uint256(0),
                abi.encode( //envelope
                    abi.encodePacked(msg.sender),
                    receiver_,
                    abi.encode( // action
                        1,
                        abi.encodePacked(
                            0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
                        ),
                        abi.encode(
                            100000000000000000,
                            3,
                            "Link Token",
                            "Link",
                            18
                        )
                    )
                )
            )
        );

        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            ccipTransmissionReceiver_,
            abi.encode(dappTransmissionInfo), // teleportPayload
            address(s_linkToken)
        );
        IRouterClient router = IRouterClient(this.getRouter());

        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        s_linkToken.approve(address(router), fees);

        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        return messageId;
    }

    function transmitNFT(
        uint64 _destinationChainSelector,
        address ccipTransmissionReceiver_,
        bytes calldata dappTransmissionReceiver_,
        bytes calldata receiver_
    ) external returns (bytes32 messageId) {
        bytes[] memory actions = new bytes[](1);
        string[] memory tokenURIs = new string[](1);
        tokenURIs[
            0
        ] = "https://ipfs.io/ipfs/QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/9843";

        uint8 chainId = 8;

        actions[1] = abi.encode(
            1,
            abi.encodePacked(0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846),
            abi.encode(
                new uint256[](1),
                chainId,
                tokenURIs,
                "BoredApeYachtClub",
                "BYC"
            )
        );

        DappTransmissionInfo memory dappTransmissionInfo = DappTransmissionInfo(
            abi.encodePacked(msg.sender),
            dappTransmissionReceiver_,
            0xc11c6ca05f75141386225b56d20e5d168000eb84f1244a4d1e001968bc5fe280,
            abi.encode( // Payload
                uint256(0),
                abi.encode(abi.encodePacked(msg.sender), receiver_, actions)
            )
        );

        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            ccipTransmissionReceiver_,
            abi.encode(dappTransmissionInfo), // teleportPayload
            address(s_linkToken)
        );
        IRouterClient router = IRouterClient(this.getRouter());

        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        s_linkToken.approve(address(router), fees);

        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        return messageId;
    }

    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        s_lastReceivedMessageId = any2EvmMessage.messageId;
        receivedMessageIds.push(any2EvmMessage.messageId);
    }

    function _buildCCIPMessage(
        address _receiver,
        bytes memory _payload,
        address _feeTokenAddress
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(_receiver), // ABI-encoded receiver address
                data: _payload, // ABI-encoded string
                tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array aas no tokens are transferred
                extraArgs: Client._argsToBytes(
                    // Additional arguments, setting gas limit and non-strict sequencing mode
                    Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false})
                ),
                // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
                feeToken: _feeTokenAddress
            });
    }

    /// @notice Fetches the details of the last received message.
    /// @return messageId The ID of the last received message.
    function getLastReceivedMessageId()
        external
        view
        returns (bytes32 messageId)
    {
        return (s_lastReceivedMessageId);
    }

    /// @notice Fetches the details of all received message.
    /// @return messageIds The IDs of all received messages.
    function getAllReceivedMessagesIds()
        external
        view
        returns (bytes32[] memory messageIds)
    {
        return (receivedMessageIds);
    }

    /// @notice Allows the contract owner to withdraw the entire balance of Ether from the contract.
    /// @dev This function reverts if there are no funds to withdraw or if the transfer fails.
    /// It should only be callable by the owner of the contract.
    /// @param _beneficiary The address to which the Ether should be sent.
    function withdraw(address _beneficiary) public onlyOwner {
        uint256 amount = address(this).balance;

        if (amount == 0) revert NothingToWithdraw();

        // Attempt to send the funds, capturing the success status and discarding any return data
        (bool sent, ) = _beneficiary.call{value: amount}("");

        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    /// @notice Fallback function to allow the contract to receive Ether.
    /// @dev This function has no function body, making it a default function for receiving Ether.
    /// It is automatically called when Ether is sent to the contract without any data.
    receive() external payable {}
}

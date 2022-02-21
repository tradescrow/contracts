// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
* @title Trade & Escrow v1.2.0
* @author @DirtyCajunRice
*/
contract Tradescrow is Ownable, ReentrancyGuard, Pausable, ERC721Holder, ERC1155Holder {

    // Use SafeERC20 for best practice
    using SafeERC20 for IERC20;
    // Counter to separate swaps
    using Counters for Counters.Counter;
    Counters.Counter private _swapsCounter;
    // Native asset locked temporary storage - in wei
    uint256 private _native;
    // Native asset fee storage - in wei
    uint256 public fee;
    // uint256 booleans to save the boolean conversion gas cost
    uint256 private constant TRUEINT = 1;
    uint256 private constant FALSEINT = 2;

    // Storage mapping for swaps
    mapping (uint256 => Swap) private _swaps;

    // NFT struct to hold the data required to create and reference an ERC721/ERC1155 object
    struct Nft {
        address addr;
        uint256 amount;
        uint256 id;
    }

    // Coin struct to hold the data required to create and reference an ERC20 object
    struct Coin {
        address addr;
        uint256 amount;
    }

    // Offer struct to hold the data for a single participant's offer
    struct Offer {
        address payable addr;
        uint256 native;
        Nft[] nfts;
        Coin[] coins;
    }

    // Swap struct to hold the data for a single swap transaction
    struct Swap {
        Offer initiator;
        Offer target;
        uint256 open;
    }

    event SwapProposed(address indexed from, address indexed to, uint256 indexed swapId, Offer);
    event SwapInitiated(address indexed from, address indexed to, uint256 indexed swapId, Offer);
    event SwapExecuted(address indexed from, address indexed to, uint256 indexed swapId);
    event SwapCancelled(address indexed cancelledBy, uint256 indexed swapId);
    event SwapClosed(uint256 indexed swapId);
    event AppFeeChanged(uint256 fee);

    // Sets the initial fee and assigns ownership
    constructor(uint256 initialAppFee, address payable contractOwnerAddress) {
        fee = initialAppFee;
        super.transferOwnership(contractOwnerAddress);
    }

    // Modifies requests that require a fee to take place
    modifier chargeAppFee() {
        require(
            msg.value >= fee,
            "Tradescrow: Sent amount needs to be greater than or equal to the application fee"
        );
        _;
    }

    /**
    * @notice Propose a new swap and pay the app fee
    *
    * @dev Step 1: User proposes a swap to another address that contains any combination of
    *      NFTs (ERC721), coins (ERC20), and native asset (base coin ~= ETH). All proposed
    *      assets are transferred to this contract and kept there until the swap is either
    *      accepted or cancelled.
    *
    * @param target Address that the initiating user wants to trade with
    * @param offer Struct that defines the proposed offer
    *
    * @return swapId ID of the new swap
    */
    function proposeSwap(address payable target, Offer memory offer)
    external payable nonReentrant chargeAppFee whenNotPaused returns(uint256) {
        requireNotEmpty(offer);
        _swapsCounter.increment();

        safeMultipleTransfersFrom(payable(msg.sender), address(this), offer);

        Swap storage swap = _swaps[_swapsCounter.current()];

        swap.open = TRUEINT;
        swap.initiator.addr = payable(msg.sender);
        for (uint256 i=0; i < offer.nfts.length; i++) {
            swap.initiator.nfts.push(offer.nfts[i]);
        }
        for (uint256 i=0; i < offer.coins.length; i++) {
            swap.initiator.coins.push(offer.coins[i]);
        }
        if (msg.value > fee) {
            swap.initiator.native = msg.value - fee;
            _native += swap.initiator.native;
        }
        swap.target.addr = target;

        emit SwapProposed(msg.sender, target, _swapsCounter.current(), offer);

        return _swapsCounter.current();
    }

    /**
    * @notice Initiate a response offer to a swap proposed to you and pay the app fee
    *
    * @dev Step 2: Proposed user agrees to the the assets offered from the initiating
    *      party by responding with their offer that contains any combination of
    *      NFTs (ERC721), coins (ERC20), and native asset (base coin ~= ETH). All proposed
    *      assets are transferred to this contract and kept there until the swap is either
    *      accepted or cancelled. This can only be called by a user with a pending swap.
    *
    * @param swapId ID of the swap that the target user is invited to participate in
    * @param offer Struct that defines the proposed response offer
    */
    function initiateSwap(uint256 swapId, Offer memory offer) external payable nonReentrant chargeAppFee whenNotPaused {
        onlyTarget(swapId);
        require(isEmpty(_swaps[swapId].target) == TRUEINT,
            "Tradescrow: swap already initiated"
        );
        require(_swaps[swapId].open == TRUEINT, "Tradescrow: Swap closed. Only user cancel enabled");
        requireNotEmpty(offer);

        safeMultipleTransfersFrom(
            payable(msg.sender),
            address(this),
            offer
        );

        for (uint256 i=0; i < offer.nfts.length; i++) {
            _swaps[swapId].target.nfts.push(offer.nfts[i]);
        }
        for (uint256 i=0; i < offer.coins.length; i++) {
            _swaps[swapId].target.coins.push(offer.coins[i]);
        }
        if (msg.value > fee) {
            _swaps[swapId].target.native = msg.value - fee;
            _native += _swaps[swapId].target.native;
        }

        emit SwapInitiated(
            msg.sender,
            _swaps[swapId].initiator.addr,
            swapId,
            offer
        );
    }

    /**
    * @notice Accept the proposed swap offer sent from the target
    *
    * @dev Step 3: Swap initiator accepts the proposed swap from the target, which transfers
    *      all assets to their intended parties from this contract. This can only be called by
    *      the initiator of the swap, and only when the target has proposed their offer
    *
    * @param swapId ID of the swap that the initiator wants to execute
    */
    function acceptSwap(uint256 swapId) external nonReentrant whenNotPaused {
        onlyInitiator(swapId);
        require(_swaps[swapId].open == TRUEINT, "Tradescrow: Swap closed. Only user cancel enabled");
        requireNotEmpty(_swaps[swapId].initiator);
        requireNotEmpty(_swaps[swapId].target);

        // transfer NFTs from escrow to initiator
        safeMultipleTransfersFrom(address(this), _swaps[swapId].initiator.addr, _swaps[swapId].target);

        // transfer NFTs from escrow to second user
        safeMultipleTransfersFrom(address(this), _swaps[swapId].target.addr, _swaps[swapId].initiator);

        transferNative(_swaps[swapId].initiator, _swaps[swapId].target);
        transferNative(_swaps[swapId].target, _swaps[swapId].initiator);

        emit SwapExecuted(_swaps[swapId].initiator.addr, _swaps[swapId].target.addr, swapId);

        delete _swaps[swapId];
    }

    /**
    * @notice Cancel the incomplete swap, returning all assets to their original owners
    * @dev Reverts all prior deposits, sending the assets back to their original owners
    *
    * @param swapId ID of the swap that the swap participants want to cancel
    */
    function cancelSwap(uint256 swapId) external nonReentrant whenNotPaused {
        require(
            _swaps[swapId].initiator.addr == msg.sender || _swaps[swapId].target.addr == msg.sender,
            "Tradescrow: Can't cancel swap, must be swap participant"
        );

        _swaps[swapId].open = FALSEINT;

        if (_swaps[swapId].initiator.addr == msg.sender) {
            safeMultipleTransfersFrom(address(this), _swaps[swapId].initiator.addr, _swaps[swapId].initiator);
            transferNative(_swaps[swapId].initiator, _swaps[swapId].initiator);
            wipeOffer(_swaps[swapId].initiator);
        } else if (_swaps[swapId].target.addr == msg.sender) {
            safeMultipleTransfersFrom(address(this), _swaps[swapId].target.addr, _swaps[swapId].target);
            transferNative(_swaps[swapId].target, _swaps[swapId].target);
            wipeOffer(_swaps[swapId].target);
        }

        emit SwapCancelled(msg.sender, swapId);

        if (isEmpty(_swaps[swapId].initiator) == TRUEINT && isEmpty(_swaps[swapId].target) == TRUEINT) {
            emit SwapClosed(swapId);
            delete _swaps[swapId];
        }
    }

    // External Owner Functions

    /**
    * @notice Update the fee charged to each user for a swap
    * @dev Can only be called by the contract owner
    *
    * @param newFee Fee in wei
    */
    function updateAppFee(uint newFee) external nonReentrant onlyOwner {
        fee = newFee;
        emit AppFeeChanged(newFee);
    }

    function Pause() external nonReentrant onlyOwner {
        _pause();
    }

    function Unpause() external nonReentrant onlyOwner {
        _unpause();
    }

    /**
    * @notice Withdraw accrued fees from the contract to an address
    * @dev Can only be called by the contract owner, and always leaves 1e18 native for gas
    *
    * @param recipient Ox address of the recipient
    */
    function withdrawFees(address payable recipient) external nonReentrant onlyOwner {
        require(recipient != address(0), "Tradescrow: transfer to the zero address");

        require(address(this).balance - _native - 1 ether >= 0, "Tradescrow: No available fees");

        recipient.transfer(address(this).balance - _native - 1 ether);
    }

    // Internal Functions

    function onlyInitiator(uint256 swapId) internal virtual {
        require(
            msg.sender == _swaps[swapId].initiator.addr,
            "Tradescrow: caller is not swap initiator"
        );
    }

    function onlyTarget(uint256 swapId) internal virtual {
        require(
            msg.sender == _swaps[swapId].target.addr,
            "Tradescrow: caller is not swap target"
        );
    }

    function requireEmpty(Offer memory offer) internal virtual {
        require(FALSEINT == isNotEmpty(offer),
            "Tradescrow: Assets exist"
        );
    }

    function requireNotEmpty(Offer memory offer) internal virtual {
        require(TRUEINT == isNotEmpty(offer),
            "Tradescrow: Can't accept offer, participant didn't add assets"
        );
    }

    function isNotEmpty(Offer memory offer) internal virtual returns(uint256) {
        uint256 empty = FALSEINT;
        if (offer.nfts.length != 0 || offer.coins.length != 0 || offer.native >= 0) {
            empty = TRUEINT;
        }
        return empty;
    }

    function isEmpty(Offer memory offer) internal virtual returns(uint256) {
        uint256 empty = FALSEINT;
        if (offer.nfts.length == 0 && offer.coins.length == 0 && offer.native == 0) {
            empty = TRUEINT;
        }
        return empty;
    }

    function wipeOffer(Offer storage offer) internal virtual {
        delete offer.coins;
        delete offer.nfts;
        offer.native = 0;
    }

    function safeMultipleTransfersFrom(address from, address to, Offer memory offer) internal virtual {
        for (uint256 i=0; i < offer.nfts.length; i++) {
            if (offer.nfts[i].amount == 0) {
                IERC721(offer.nfts[i].addr).safeTransferFrom(from, to, offer.nfts[i].id, "");
            } else {
                IERC1155(offer.nfts[i].addr).safeTransferFrom(from, to, offer.nfts[i].id, offer.nfts[i].amount, "");
            }
        }
        for (uint256 i=0; i < offer.coins.length; i++) {
            if (from == address(this)) {
                IERC20(offer.coins[i].addr).safeTransfer(to, offer.coins[i].amount);
            } else {
                IERC20(offer.coins[i].addr).safeTransferFrom(from, to, offer.coins[i].amount);
            }
        }
    }

    function transferNative(Offer storage from, Offer storage to) internal virtual {
        if (from.native > 0) {
            _native -= from.native;
            uint native = from.native;
            from.native = 0;
            to.addr.transfer(native);
        }
    }
}
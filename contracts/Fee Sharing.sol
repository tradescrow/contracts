// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
* @title Tradescrow Fee Sharing v1.0.0
* @author @DirtyCajunRice
*/
contract TradescrowFeeSharing {
    // Use SafeERC20 for best practice
    using SafeERC20 for IERC20;

    uint256 private _totalShare;
    uint256 private _totalReleased;



    mapping(address => uint256) private _share;
    mapping(address => uint256) private _released;
    address[] private _beneficiary;

    mapping(SafeERC20 => uint256) private _erc20TotalReleased;
    mapping(SafeERC20 => mapping(address => uint256)) private _erc20Released;


    struct ScalingCondition {

    }

    // Beneficiary struct to hold the details of a single beneficiary
    struct Beneficiary {
        address payable addr;
        uint256 baseShare;
        bool scaling;
        ScalingCondition[] _conditions;
    }

    event BeneficiaryAdded(
        address indexed addr,
        uint256 indexed baseShare,
        bool indexed scaling,
        ScalingCondition[] conditions
    );
    event PaymentReleased(address indexed to, uint256 amount);
    event ERC20PaymentReleased(IERC20 indexed token, address indexed to, uint256 amount);
    event PaymentReceived(address indexed from, uint256 amount);

    constructor(Beneficiary[] memory beneficiaries) payable {
        require(beneficiaries.length > 0, "TradescrowFeeSharing: no beneficiaries");
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(beneficiaries[i].baseShare > 0, "TradescrowFeeSharing: beneficiary missing base share");
            if (beneficiaries[i].scaling) {
                require(beneficiaries[i].conditions.length > 0, "TradescrowFeeSharing: beneficiary missing conditions");
            }
        }
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            _addBeneficiary(beneficiaries[i]);
        }
    }

    /**
     * @dev The ONE received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive ONE without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of ONE.
     */
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    /**
     * @dev Getter for the total share held by beneficiaries.
     */
    function totalShare() public view returns (uint256) {
        return _totalShare;
    }

    /**
     * @dev Getter for the total amount of ONE already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the total amount of `token` already released. `token` should be the address of a SafeERC20
     * contract.
     */
    function totalReleased(IERC20 token) public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    /**
     * @dev Getter for the amount of share held by an account.
     */
    function share(address account) public view returns (uint256) {
        return _share[account];
    }

    /**
     * @dev Getter for the amount of ONE already released to a beneficiary.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an
     * SafeERC20 contract.
     */
    function released(IERC20 token, address account) public view returns (uint256) {
        return _erc20Released[token][account];
    }

    /**
     * @dev Getter for the address of the beneficiary number `index`.
     */
    function beneficiary(uint256 index) public view returns (address) {
        return _beneficiary[index];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their
     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20
     * contract.
     */
    function release(IERC20 token, address account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);
        uint256 payment = _pendingPayment(account, totalReceived, released(token, account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _erc20Released[token][account] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    /**
     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and
     * already released amounts.
     */
    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    /**
     * @dev Add a new beneficiary to the contract.
     * @param account The address of the beneficiary to add.
     * @param share_ The number of percent owned by the payee.
     */
    function _addBeneficiary(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }
}
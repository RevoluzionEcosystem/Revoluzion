/*

██████  ███████ ██    ██  ██████  ██      ██    ██ ███████ ██  ██████  ███    ██                   
██   ██ ██      ██    ██ ██    ██ ██      ██    ██     ██  ██ ██    ██ ████   ██                  
██████  █████   ██    ██ ██    ██ ██      ██    ██   ██    ██ ██    ██ ██ ██  ██                   
██   ██ ██       ██  ██  ██    ██ ██      ██    ██  ██     ██ ██    ██ ██  ██ ██                   
██   ██ ███████   ████    ██████  ███████  ██████  ███████ ██  ██████  ██   ████              

Revoluzion Ecosystem
https://revoluzion.app

Revoluzion Multisender - A smart contract enabling batch transfers of native, tokens, or multiple type of tokens to multiple recipients with varying amounts.

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title IMultiSenderEvents
 * @dev Interface containing all events emitted by the RevoluzionMultisender contract
 */
interface IMultiSenderEvents {
    /**
     * @dev Emitted when native currency is sent to multiple recipients
     * @param sender The address that initiated the batch transaction
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts sent to each recipient
     * @param totalAmount Total amount of native currency sent
     */
    event NativeCurrencyMultiSend(
        address indexed sender,
        address[] recipients,
        uint256[] amounts,
        uint256 totalAmount
    );

    /**
     * @dev Emitted when tokens are sent to multiple recipients
     * @param sender The address that initiated the batch transaction
     * @param token The token contract address
     * @param recipients Array of recipient addresses
     * @param amounts Array of token amounts sent to each recipient
     * @param totalAmount Total amount of tokens sent
     */
    event TokenMultiSend(
        address indexed sender,
        address indexed token,
        address[] recipients,
        uint256[] amounts,
        uint256 totalAmount
    );

    /**
     * @dev Emitted when the same token amount is sent to multiple recipients
     * @param sender The address that initiated the batch transaction
     * @param token The token contract address
     * @param recipients Array of recipient addresses
     * @param amount Amount sent to each recipient
     * @param totalAmount Total amount of tokens sent
     */
    event TokenMultiSendEqual(
        address indexed sender,
        address indexed token,
        address[] recipients,
        uint256 amount,
        uint256 totalAmount
    );

    /**
     * @dev Emitted when the same native currency amount is sent to multiple recipients
     * @param sender The address that initiated the batch transaction
     * @param recipients Array of recipient addresses
     * @param amount Amount sent to each recipient
     * @param totalAmount Total amount of native currency sent
     */
    event NativeCurrencyMultiSendEqual(
        address indexed sender,
        address[] recipients,
        uint256 amount,
        uint256 totalAmount
    );

    /**
     * @dev Emitted when fees are collected
     * @param collector The address that collected the fees
     * @param amount Amount of fees collected
     */
    event FeesCollected(address indexed collector, uint256 amount);

    /**
     * @dev Emitted when the fee rate is updated
     * @param oldFeeRate The previous fee rate
     * @param newFeeRate The new fee rate
     */
    event FeeRateUpdated(uint256 oldFeeRate, uint256 newFeeRate);

    /**
     * @dev Emitted when the fee collector address is updated
     * @param oldCollector The previous fee collector address
     * @param newCollector The new fee collector address
     */
    event FeeCollectorUpdated(address oldCollector, address newCollector);
    
    /**
     * @dev Emitted when multiple different tokens are sent to recipients
     * @param sender The address that initiated the batch transaction
     * @param tokens Array of token contract addresses
     * @param recipients Array of recipient addresses
     * @param amounts Array of token amounts sent to each recipient
     */
    event MultiTokenMultiSend(
        address indexed sender,
        address[] tokens,
        address[] recipients,
        uint256[] amounts
    );
    
    /**
     * @dev Emitted when a recipient is added to the blacklist
     * @param recipient The blacklisted address
     */
    event RecipientBlacklisted(address indexed recipient);
    
    /**
     * @dev Emitted when a recipient is removed from the blacklist
     * @param recipient The address removed from blacklist
     */
    event RecipientRemovedFromBlacklist(address indexed recipient);
    
    /**
     * @dev Emitted when address limits are set
     * @param recipient The address for which limits are set
     * @param limit The maximum amount that can be sent to this address
     */
    event AddressLimitSet(address indexed recipient, uint256 limit);
    
    /**
     * @dev Emitted when the contract is paused by the owner
     * @param account The account that paused the contract
     */
    event Paused(address account);
    
    /**
     * @dev Emitted when the contract is unpaused by the owner
     * @param account The account that unpaused the contract
     */
    event Unpaused(address account);
    
    /**
     * @dev Emitted when a transaction is identified as suspicious
     * @param sender The address that initiated the suspicious transaction
     * @param transactionData Brief description of the suspicious transaction
     */
    event SuspiciousTransaction(address indexed sender, string transactionData);
    
    /**
     * @dev Emitted when a user's transaction is completed (for tracking history)
     * @param user Address of the user who executed the transaction
     * @param transactionType Type of transaction (0=native, 1=token, 2=multi-token)
     * @param timestamp Block timestamp when transaction was executed
     * @param transactionId Unique identifier for the transaction
     */
    event TransactionExecuted(
        address indexed user,
        uint8 transactionType,
        uint256 timestamp,
        bytes32 indexed transactionId
    );
    
    /**
     * @dev Emitted when user stats are updated
     * @param user Address of the user
     * @param totalTransactions Total number of transactions executed by user
     * @param totalVolume Total volume transferred by user
     */
    event UserStatsUpdated(
        address indexed user,
        uint256 totalTransactions,
        uint256 totalVolume
    );
    
    /**
     * @dev Emitted when user preferences are updated
     * @param user Address of the user
     * @param preferenceKey The key for the preference that was updated
     */
    event UserPreferenceUpdated(
        address indexed user,
        bytes32 indexed preferenceKey
    );
}

/**
 * @title IERC20Minimal
 * @dev Minimal interface for ERC20 token interactions
 */
interface IERC20Minimal {
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

/**
 * @title IERC20Errors
 * @dev Interface for common ERC20 errors
 */
interface IERC20Errors {
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
}

/**
 * @title IERC20Permit
 * @dev Interface for the ERC20 Permit extension allowing approvals via signatures
 */
interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure or attempt fallback for non-standard tokens
 * Adds support for tokens like USDT that don't consistently return boolean
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer tokens safely, working with non-standard tokens
     */
    function safeTransfer(IERC20Minimal token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer tokens from an address safely, working with non-standard tokens
     */
    function safeTransferFrom(IERC20Minimal token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Imitates a Solidity high-level call
     */
    function _callOptionalReturn(IERC20Minimal token, bytes memory data) private {
        // We need to perform a low level call
        (bool success, bytes memory returndata) = address(token).call(data);
        
        // If the low-level call didn't succeed we bubble up the revert reason if provided
        if (!success) {
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("SafeERC20: call failed");
            }
        }

        // Return data is optional - we only verify it when there actually is some return data
        if (returndata.length > 0) {
            // If the token returns data, require that the operation was successful
            require(abi.decode(returndata, (bool)), "SafeERC20: operation failed");
        }
    }
}

/**
 * @title Address
 * @dev Utility library for address operations
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     */
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    /**
     * @dev Helper function for calling a contract
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {functionCall}, but with an error message
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title Ownable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title ReentrancyGuard
 * @dev Contract module that helps prevent reentrant calls to a function.
 */
abstract contract ReentrancyGuard {
    // Booleans are cheaper than uint256 in storage slots, this variable is a counter
    // of the number of nested non-reentrant calls to the function, if it hits a
    // certain number (2^256-1), then it wraps around to 0 and the non-reentrant
    // guard is deactivated.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant from an _ENTERED function will fail
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

/**
 * @title RevoluzionMultisender
 * @dev Contract that allows sending native currency or tokens to multiple addresses in a single transaction
 * Gas-optimized with security measures against common attack vectors
 */
contract RevoluzionMultisender is Ownable, ReentrancyGuard, IMultiSenderEvents {
    using SafeERC20 for IERC20Minimal;
    
    // Maximum batch size to prevent block gas limit issues
    uint256 public constant MAX_BATCH_SIZE = 500;

    // Fee denominator for calculating fee percentages (10000 = 100%)
    uint256 private constant FEE_DENOMINATOR = 10000;

    // Current fee rate in basis points (1 = 0.01%)
    uint256 public feeRate;

    // Address that collects fees - hardcoded to Revoluzion address
    address public feeCollector = 0x9C48405d8E4d107C9DC033993d18D60F67380ca1;

    // Accumulated fees in native currency
    uint256 public accumulatedFees;
    
    // Mapping to track blacklisted recipients
    mapping(address => bool) public blacklisted;
    
    // Mapping to track limits per recipient address
    mapping(address => uint256) public addressLimits;
    
    // Mapping to track sent amounts per recipient address
    mapping(address => uint256) public sentAmounts;
    
    // Circuit breaker pattern - emergency pause
    bool public paused;
    
    // Suspicious transaction limits
    uint256 public maxAllowedTransactionValue;
    
    // Addresses that are trusted and can bypass limits
    mapping(address => bool) public trustedAddresses;
    
    // Base fee in native currency that must be paid for each transaction
    uint256 public baseFeeNative;
    
    // Allow unlimited transfers flag (no max transaction value check)
    bool public allowUnlimitedTransfers;
    
    /**
     * @dev Enumeration for transaction types
     */
    enum TransactionType {
        NativeCurrency,
        ERC20Token,
        MultiToken
    }
    
    /**
     * @dev Structure for token transfer information
     */
    struct TokenTransferInfo {
        address token;
        uint256 amount;
        uint256 timestamp;
        address recipient;
        bytes32 transactionId;
    }
    
    /**
     * @dev Structure for user statistics
     */
    struct UserStats {
        uint256 transactionCount;
        uint256 totalVolumeNative;
        uint256 totalVolumeTokens;
        uint256 lastActiveTime;
        uint256 totalFeesPaid;
        uint256 totalRecipientsServed;
    }
    
    // User statistics
    mapping(address => UserStats) public userStats;
    
    // User preferences
    mapping(address => mapping(bytes32 => bytes)) public userPreferences;
    
    // Favorites for quick access (tokens, recipients)
    mapping(address => address[]) public userFavoriteTokens;
    mapping(address => address[]) public userFavoriteRecipients;
    
    // Token transfer history tracker
    mapping(address => TokenTransferInfo[]) private tokenTransferHistory;
    
    // Global metrics for analytics
    uint256 public totalTransactionsProcessed;
    uint256 public totalTokensTransferred;
    uint256 public totalNativeCurrencyTransferred;
    
    // Max history items to store per user (to prevent excessive storage usage)
    uint256 public maxHistoryItemsPerUser = 100;
    
    // Gas refund program enabled/disabled
    bool public gasRefundProgramEnabled;
    
    // Gas refund rate in percentage (x100 for precision)
    uint256 public gasRefundRate;
    
    /**
     * @dev Structure for storing transaction details
     */
    struct TransactionDetails {
        address sender;
        uint8 transactionType; // 0=native, 1=token, 2=multi-token
        uint256 timestamp;
        uint256 totalAmount;
        uint256 recipientCount;
        uint256 fee;
        bytes extraData; // For additional metadata
    }
    
    // Transaction IDs for lookup
    mapping(bytes32 => TransactionDetails) private transactionDetails;
    
    // Global transaction counter
    uint256 private transactionCounter;
    
    /**
     * @dev Structure for high-level transaction history
     */
    struct Transaction {
        bytes32 transactionId;
        uint8 transactionType;
        uint256 timestamp;
        uint256 amount;
    }
    
    // User transaction history tracking
    mapping(address => Transaction[]) private userTransactionHistory;
    
    constructor(uint256 initialFeeRate) {
        feeRate = initialFeeRate;
        paused = false;
        maxAllowedTransactionValue = 1000 ether; // Default reasonable limit
        baseFeeNative = 0.001 ether; // Default base fee of 0.001 native tokens
        allowUnlimitedTransfers = true; // Default to allowing unlimited transfers
        
        // Make owner a trusted address
        trustedAddresses[msg.sender] = true;
    }
    
    /**
     * @dev Checks if a transaction might be suspicious based on volume
     * @param amount The transaction amount to check
     * @return isSuspicious true if transaction is suspicious
     */
    function _isSuspiciousTransaction(uint256 amount) private view returns (bool isSuspicious) {
        // If unlimited transfers is enabled, don't flag any transactions
        if (allowUnlimitedTransfers) {
            return false;
        }
        
        // Trusted addresses bypass suspicious transaction checks
        if (trustedAddresses[msg.sender]) {
            return false;
        }
        
        return amount > maxAllowedTransactionValue;
    }

    /**
     * @dev Validates that input arrays meet security requirements
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts (optional for equal distribution)
     */
    function _validateInputs(
        address[] memory recipients,
        uint256[] memory amounts
    ) private view {
        uint256 recipientsLength = recipients.length;

        // Check batch size limit
        require(recipientsLength > 0, "No recipients provided");
        require(recipientsLength <= MAX_BATCH_SIZE, "Batch size exceeds limit");

        // If amounts array is provided, ensure it matches recipients length
        if (amounts.length > 0) {
            require(
                recipientsLength == amounts.length,
                "Recipients and amounts length mismatch"
            );
        }

        // Ensure no zero addresses or blacklisted addresses in recipients
        for (uint256 i = 0; i < recipientsLength; i++) {
            require(recipients[i] != address(0), "Cannot send to zero address");
            require(!blacklisted[recipients[i]], "Recipient is blacklisted");
        }
    }
    
    /**
     * @dev Validates and enforces address limits
     * @param recipient Recipient address
     * @param amount Amount being sent to the recipient
     */
    function _enforceAddressLimits(address recipient, uint256 amount) private {
        uint256 limit = addressLimits[recipient];
        if (limit > 0) {
            uint256 newTotal = sentAmounts[recipient] + amount;
            require(newTotal <= limit, "Address limit exceeded");
            sentAmounts[recipient] = newTotal;
        }
    }

    /**
     * @dev Calculates the fee amount based on the total amount and adds base fee
     * @param amount Total amount being sent
     * @return fee Fee amount in native currency
     */
    function _calculateFee(uint256 amount) private view returns (uint256 fee) {
        // Calculate percentage-based fee
        uint256 percentageFee = (amount * feeRate) / FEE_DENOMINATOR;
        
        // Add base fee in native currency
        return percentageFee + baseFeeNative;
    }
    
    /**
     * @dev Sets base fee in native currency
     * @param newBaseFee New base fee amount
     */
    function setBaseFeeNative(uint256 newBaseFee) external onlyOwner {
        baseFeeNative = newBaseFee;
    }
    
    /**
     * @dev Enable or disable unlimited transfers (no maximum transaction value check)
     * @param allow Whether to allow unlimited transfers
     */
    function setAllowUnlimitedTransfers(bool allow) external onlyOwner {
        allowUnlimitedTransfers = allow;
    }
    
    /**
     * @dev Adds a transaction to user's history
     * @param user User address
     * @param transactionType Type of transaction
     * @param amount Transaction amount
     * @param recipientCount Number of recipients
     * @param fee Fee paid
     * @param extraData Additional transaction data
     * @return transactionId Transaction ID
     */
    function _trackTransaction(
        address user,
        uint8 transactionType,
        uint256 amount,
        uint256 recipientCount,
        uint256 fee,
        bytes memory extraData
    ) private returns (bytes32 transactionId) {
        // Generate transaction ID
        transactionId = keccak256(
            abi.encodePacked(
                user,
                transactionType,
                block.timestamp,
                transactionCounter++
            )
        );
        
        // Store transaction details
        transactionDetails[transactionId] = TransactionDetails({
            sender: user,
            transactionType: transactionType,
            timestamp: block.timestamp,
            totalAmount: amount,
            recipientCount: recipientCount,
            fee: fee,
            extraData: extraData
        });
        
        // Add to user's transaction history, limiting the size
        Transaction[] storage history = userTransactionHistory[user];
        if (history.length >= maxHistoryItemsPerUser) {
            // Remove oldest transaction if limit reached
            for (uint i = 0; i < history.length - 1; i++) {
                history[i] = history[i + 1];
            }
            history.pop();
        }
        
        // Add new transaction to history
        history.push(
            Transaction({
                transactionId: transactionId,
                transactionType: transactionType,
                timestamp: block.timestamp,
                amount: amount
            })
        );
        
        // Update user stats
        UserStats storage stats = userStats[user];
        stats.transactionCount++;
        stats.lastActiveTime = block.timestamp;
        stats.totalFeesPaid += fee;
        stats.totalRecipientsServed += recipientCount;
        
        if (transactionType == uint8(TransactionType.NativeCurrency)) {
            stats.totalVolumeNative += amount;
            totalNativeCurrencyTransferred += amount;
        } else {
            stats.totalVolumeTokens += amount;
            totalTokensTransferred += amount;
        }
        
        // Update global metrics
        totalTransactionsProcessed++;
        
        // Emit events
        emit TransactionExecuted(
            user,
            transactionType,
            block.timestamp,
            transactionId
        );
        
        emit UserStatsUpdated(
            user,
            stats.transactionCount,
            transactionType == uint8(TransactionType.NativeCurrency) ? stats.totalVolumeNative : stats.totalVolumeTokens
        );
        
        return transactionId;
    }
    
    /**
     * @dev Modifier to make a function callable only when the contract is not paused or by the owner
     */
    modifier whenNotPausedOrOwner() {
        require(!paused || msg.sender == owner(), "Contract is paused");
        _;
    }
    
    /**
     * @dev Sends native currency to multiple recipients with different amounts
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts to send to each recipient
     */
    function sendNativeCurrency(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external payable nonReentrant whenNotPausedOrOwner {
        _validateInputs(recipients, amounts);

        // Calculate total amount and ensure sufficient funds
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "Amount must be greater than 0");
            totalAmount += amounts[i];
        }

        // Check for suspicious transactions
        if (_isSuspiciousTransaction(totalAmount)) {
            emit SuspiciousTransaction(msg.sender, "High value native currency multi-send");
        }

        // Calculate and validate fee
        uint256 fee = _calculateFee(msg.value);
        require(msg.value >= totalAmount + fee, "Insufficient funds sent");

        // Accumulate fees
        accumulatedFees += fee;

        // Send to each recipient
        for (uint256 i = 0; i < recipients.length; i++) {
            _enforceAddressLimits(recipients[i], amounts[i]);
            (bool success, ) = recipients[i].call{value: amounts[i]}("");
            require(success, "Native currency transfer failed");
        }

        // Refund excess if any
        uint256 excess = msg.value - (totalAmount + fee);
        if (excess > 0) {
            (bool success, ) = msg.sender.call{value: excess}("");
            require(success, "Refund failed");
        }

        // Track transaction
        bytes memory extraData = abi.encode(recipients, amounts);
        _trackTransaction(
            msg.sender,
            uint8(TransactionType.NativeCurrency),
            totalAmount,
            recipients.length,
            fee,
            extraData
        );

        emit NativeCurrencyMultiSend(
            msg.sender,
            recipients,
            amounts,
            totalAmount
        );
    }

    /**
     * @dev Sends the same amount of native currency to multiple recipients
     * @param recipients Array of recipient addresses
     * @param amountEach Amount to send to each recipient
     */
    function sendNativeCurrencyEqual(
        address[] calldata recipients,
        uint256 amountEach
    ) external payable nonReentrant whenNotPausedOrOwner {
        // Create an empty array for _validateInputs
        uint256[] memory emptyAmounts = new uint256[](0);
        _validateInputs(recipients, emptyAmounts);
        
        require(amountEach > 0, "Amount must be greater than 0");

        uint256 recipientsLength = recipients.length;
        uint256 totalAmount = amountEach * recipientsLength;

        // Check for suspicious transactions
        if (_isSuspiciousTransaction(totalAmount)) {
            emit SuspiciousTransaction(msg.sender, "High value native currency equal multi-send");
        }

        // Calculate and validate fee
        uint256 fee = _calculateFee(msg.value);
        require(msg.value >= totalAmount + fee, "Insufficient funds sent");

        // Accumulate fees
        accumulatedFees += fee;

        // Send to each recipient - using optimized loop
        unchecked {
            for (uint256 i = 0; i < recipientsLength; i++) {
                _enforceAddressLimits(recipients[i], amountEach);
                (bool success, ) = recipients[i].call{value: amountEach}("");
                require(success, "Native currency transfer failed");
            }
        }

        // Refund excess if any
        uint256 excess = msg.value - (totalAmount + fee);
        if (excess > 0) {
            (bool success, ) = msg.sender.call{value: excess}("");
            require(success, "Refund failed");
        }
        
        // Track transaction
        bytes memory extraData = abi.encode(recipients, amountEach);
        _trackTransaction(
            msg.sender,
            uint8(TransactionType.NativeCurrency),
            totalAmount,
            recipientsLength,
            fee,
            extraData
        );

        emit NativeCurrencyMultiSendEqual(
            msg.sender,
            recipients,
            amountEach,
            totalAmount
        );
    }

    /**
     * @dev Sends tokens to multiple recipients with different amounts using SafeERC20
     * @param token Token contract address
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts to send to each recipient
     */
    function sendToken(
        address token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external payable nonReentrant whenNotPausedOrOwner {
        _validateInputs(recipients, amounts);
        require(token != address(0), "Token address cannot be zero");

        // Calculate total amount
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "Amount must be greater than 0");
            totalAmount += amounts[i];
        }

        // Check for suspicious transactions based on token volume
        if (recipients.length >= MAX_BATCH_SIZE / 2) {
            emit SuspiciousTransaction(msg.sender, "Large batch token transfer");
        }

        // Calculate and collect fee in native currency
        uint256 fee = _calculateFee(msg.value);
        require(msg.value >= fee, "Insufficient fee");
        accumulatedFees += fee;

        // Refund excess fee if any
        uint256 excess = msg.value - fee;
        if (excess > 0) {
            (bool success, ) = msg.sender.call{value: excess}("");
            require(success, "Excess fee refund failed");
        }

        // Transfer tokens from sender to recipients using SafeERC20
        IERC20Minimal tokenContract = IERC20Minimal(token);

        for (uint256 i = 0; i < recipients.length; i++) {
            _enforceAddressLimits(recipients[i], amounts[i]);
            SafeERC20.safeTransferFrom(
                tokenContract,
                msg.sender,
                recipients[i],
                amounts[i]
            );
            
            // Track individual token transfers for detailed history
            if (tokenTransferHistory[msg.sender].length < maxHistoryItemsPerUser) {
                bytes32 txId = keccak256(abi.encodePacked(msg.sender, token, block.timestamp, i));
                tokenTransferHistory[msg.sender].push(
                    TokenTransferInfo({
                        token: token,
                        amount: amounts[i],
                        timestamp: block.timestamp,
                        recipient: recipients[i],
                        transactionId: txId
                    })
                );
            }
        }
        
        // Track transaction
        bytes memory extraData = abi.encode(token, recipients, amounts);
        _trackTransaction(
            msg.sender,
            uint8(TransactionType.ERC20Token),
            totalAmount,
            recipients.length,
            fee,
            extraData
        );

        emit TokenMultiSend(
            msg.sender,
            token,
            recipients,
            amounts,
            totalAmount
        );
    }

    /**
     * @dev Sends the same amount of tokens to multiple recipients using SafeERC20
     * @param token Token contract address
     * @param recipients Array of recipient addresses
     * @param amountEach Amount to send to each recipient
     */
    function sendTokenEqual(
        address token,
        address[] calldata recipients,
        uint256 amountEach
    ) external payable nonReentrant whenNotPausedOrOwner {
        // Create an empty array for _validateInputs
        uint256[] memory emptyAmounts = new uint256[](0);
        _validateInputs(recipients, emptyAmounts);
        
        require(token != address(0), "Token address cannot be zero");
        require(amountEach > 0, "Amount must be greater than 0");

        uint256 recipientsLength = recipients.length;
        uint256 totalAmount = amountEach * recipientsLength;

        // Check for suspicious transactions based on token volume
        if (recipients.length >= MAX_BATCH_SIZE / 2) {
            emit SuspiciousTransaction(msg.sender, "Large batch equal token transfer");
        }

        // Calculate and collect fee in native currency
        uint256 fee = _calculateFee(msg.value);
        require(msg.value >= fee, "Insufficient fee");
        accumulatedFees += fee;

        // Refund excess fee if any
        uint256 excess = msg.value - fee;
        if (excess > 0) {
            (bool success, ) = msg.sender.call{value: excess}("");
            require(success, "Excess fee refund failed");
        }

        // Transfer tokens from sender to recipients using SafeERC20
        IERC20Minimal tokenContract = IERC20Minimal(token);

        // Using unchecked for gas optimization since we already checked for overflow
        unchecked {
            for (uint256 i = 0; i < recipientsLength; i++) {
                _enforceAddressLimits(recipients[i], amountEach);
                SafeERC20.safeTransferFrom(
                    tokenContract,
                    msg.sender,
                    recipients[i],
                    amountEach
                );
                
                // Track individual token transfers for detailed history
                if (tokenTransferHistory[msg.sender].length < maxHistoryItemsPerUser) {
                    bytes32 txId = keccak256(abi.encodePacked(msg.sender, token, block.timestamp, i));
                    tokenTransferHistory[msg.sender].push(
                        TokenTransferInfo({
                            token: token,
                            amount: amountEach,
                            timestamp: block.timestamp,
                            recipient: recipients[i],
                            transactionId: txId
                        })
                    );
                }
            }
        }
        
        // Track transaction
        bytes memory extraData = abi.encode(token, recipients, amountEach);
        _trackTransaction(
            msg.sender,
            uint8(TransactionType.ERC20Token),
            totalAmount,
            recipientsLength,
            fee,
            extraData
        );

        emit TokenMultiSendEqual(
            msg.sender,
            token,
            recipients,
            amountEach,
            totalAmount
        );
    }
    
    /**
     * @dev Sends multiple different tokens to multiple recipients with different amounts
     * @param tokens Array of token contract addresses
     * @param recipients Array of recipient addresses
     * @param amounts Array of token amounts to send to each recipient
     * Requirements:
     * - tokens.length == recipients.length == amounts.length
     * - All arrays must have the same length and each triplet (token, recipient, amount) forms a transfer operation
     */
    function sendMultipleTokens(
        address[] calldata tokens,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external payable nonReentrant whenNotPausedOrOwner {
        uint256 length = tokens.length;
        require(length > 0, "No transfers provided");
        require(length <= MAX_BATCH_SIZE, "Batch size exceeds limit");
        require(recipients.length == length && amounts.length == length, 
                "Array lengths mismatch");
        
        // Check for suspicious transactions
        if (tokens.length >= MAX_BATCH_SIZE / 3) {
            emit SuspiciousTransaction(msg.sender, "Large multi-token batch transfer");
        }
        
        // Calculate and collect fee in native currency
        uint256 fee = _calculateFee(msg.value);
        require(msg.value >= fee, "Insufficient fee");
        accumulatedFees += fee;
        
        // Refund excess fee if any
        uint256 excess = msg.value - fee;
        if (excess > 0) {
            (bool success, ) = msg.sender.call{value: excess}("");
            require(success, "Excess fee refund failed");
        }
        
        // Process each token transfer
        uint256 totalValue = 0;
        for (uint256 i = 0; i < length; i++) {
            require(tokens[i] != address(0), "Token address cannot be zero");
            require(recipients[i] != address(0), "Cannot send to zero address");
            require(!blacklisted[recipients[i]], "Recipient is blacklisted");
            require(amounts[i] > 0, "Amount must be greater than 0");
            
            _enforceAddressLimits(recipients[i], amounts[i]);
            totalValue += amounts[i]; // Note: This doesn't account for token decimals
            
            IERC20Minimal token = IERC20Minimal(tokens[i]);
            SafeERC20.safeTransferFrom(
                token,
                msg.sender,
                recipients[i],
                amounts[i]
            );
            
            // Track individual token transfers for detailed history
            if (tokenTransferHistory[msg.sender].length < maxHistoryItemsPerUser) {
                bytes32 txId = keccak256(abi.encodePacked(msg.sender, tokens[i], block.timestamp, i));
                tokenTransferHistory[msg.sender].push(
                    TokenTransferInfo({
                        token: tokens[i],
                        amount: amounts[i],
                        timestamp: block.timestamp,
                        recipient: recipients[i],
                        transactionId: txId
                    })
                );
            }
        }
        
        // Track transaction
        bytes memory extraData = abi.encode(tokens, recipients, amounts);
        _trackTransaction(
            msg.sender,
            uint8(TransactionType.MultiToken),
            totalValue,
            length,
            fee,
            extraData
        );
        
        emit MultiTokenMultiSend(
            msg.sender,
            tokens,
            recipients,
            amounts
        );
    }
    
    /**
     * @dev Pause the contract (circuit breaker)
     */
    function pause() external onlyOwner {
        require(!paused, "Contract is already paused");
        paused = true;
        emit Paused(msg.sender);
    }
    
    /**
     * @dev Unpause the contract
     */
    function unpause() external onlyOwner {
        require(paused, "Contract is not paused");
        paused = false;
        emit Unpaused(msg.sender);
    }
    
    /**
     * @dev Set maximum allowed transaction value for suspicious transaction detection
     * @param maxValue The maximum value in wei
     */
    function setMaxAllowedTransactionValue(uint256 maxValue) external onlyOwner {
        maxAllowedTransactionValue = maxValue;
    }
    
    /**
     * @dev Add or remove trusted address status
     * @param addr Address to modify trusted status
     * @param isTrusted New trusted status
     */
    function setTrustedAddress(address addr, bool isTrusted) external onlyOwner {
        require(addr != address(0), "Cannot set status for zero address");
        trustedAddresses[addr] = isTrusted;
    }

    /**
     * @dev Add or update address limits
     * @param recipient The address to set limits for
     * @param limit The maximum amount that can be sent to this address
     */
    function setAddressLimit(address recipient, uint256 limit) external onlyOwner {
        require(recipient != address(0), "Cannot set limit for zero address");
        addressLimits[recipient] = limit;
        emit AddressLimitSet(recipient, limit);
    }
    
    /**
     * @dev Add address to blacklist
     * @param recipient The address to blacklist
     */
    function blacklistAddress(address recipient) external onlyOwner {
        require(recipient != address(0), "Cannot blacklist zero address");
        blacklisted[recipient] = true;
        emit RecipientBlacklisted(recipient);
    }
    
    /**
     * @dev Remove address from blacklist
     * @param recipient The address to remove from blacklist
     */
    function removeFromBlacklist(address recipient) external onlyOwner {
        require(blacklisted[recipient], "Address not blacklisted");
        blacklisted[recipient] = false;
        emit RecipientRemovedFromBlacklist(recipient);
    }

    /**
     * @dev Allows owner to update the fee rate
     * @param newFeeRate New fee rate in basis points (1 = 0.01%)
     */
    function setFeeRate(uint256 newFeeRate) external onlyOwner {
        require(newFeeRate <= 300, "Fee rate cannot exceed 3%");

        uint256 oldFeeRate = feeRate;
        feeRate = newFeeRate;

        emit FeeRateUpdated(oldFeeRate, newFeeRate);
    }

    /**
     * @dev Allows owner to update the fee collector address
     * @param newFeeCollector New fee collector address
     */
    function setFeeCollector(address newFeeCollector) external onlyOwner {
        require(
            newFeeCollector != address(0),
            "Fee collector cannot be zero address"
        );

        address oldFeeCollector = feeCollector;
        feeCollector = newFeeCollector;

        emit FeeCollectorUpdated(oldFeeCollector, newFeeCollector);
    }

    /**
     * @dev Collects accumulated fees
     */
    function collectFees() external nonReentrant {
        require(
            msg.sender == feeCollector,
            "Only fee collector can collect fees"
        );
        require(accumulatedFees > 0, "No fees to collect");

        uint256 amount = accumulatedFees;
        accumulatedFees = 0;

        (bool success, ) = feeCollector.call{value: amount}("");
        require(success, "Fee collection failed");

        emit FeesCollected(feeCollector, amount);
    }
    
    /**
     * @dev Reset sent amount tracking for an address
     * @param recipient The address to reset tracking for
     */
    function resetSentAmount(address recipient) external onlyOwner {
        require(recipient != address(0), "Cannot reset for zero address");
        sentAmounts[recipient] = 0;
    }
    
    /**
     * @dev Reset transaction counter for an address
     * @param user The address to reset counter for
     */
    function resetTransactionCounter(address user) external onlyOwner {
        require(user != address(0), "Cannot reset for zero address");
        
        // Reset transaction counter in user stats
        userStats[user].transactionCount = 0;
        
        // Add a record of when this reset happened
        bytes32 resetKey = keccak256("TRANSACTION_COUNTER_RESET");
        userPreferences[user][resetKey] = abi.encode(block.timestamp);
        
        // Optional: emit an event for tracking
        emit UserStatsUpdated(user, 0, userStats[user].totalVolumeNative);
    }
    
    /**
     * @dev Sets a user preference
     * @param key Preference key
     * @param value Preference value
     */
    function setUserPreference(bytes32 key, bytes calldata value) external {
        userPreferences[msg.sender][key] = value;
        emit UserPreferenceUpdated(msg.sender, key);
    }
    
    /**
     * @dev Gets a user preference
     * @param user User address
     * @param key Preference key
     * @return preferenceValue Preference value
     */
    function getUserPreference(address user, bytes32 key) external view returns (bytes memory preferenceValue) {
        return userPreferences[user][key];
    }
    
    /**
     * @dev Adds a token to user's favorites
     * @param token Token address to add to favorites
     */
    function addFavoriteToken(address token) external {
        require(token != address(0), "Cannot add zero address to favorites");
        
        // Check if token already exists in favorites
        address[] storage favorites = userFavoriteTokens[msg.sender];
        for (uint256 i = 0; i < favorites.length; i++) {
            if (favorites[i] == token) {
                return; // Already in favorites
            }
        }
        
        // Add to favorites (limit to 50 favorites)
        if (favorites.length < 50) {
            favorites.push(token);
        }
    }
    
    /**
     * @dev Removes a token from user's favorites
     * @param token Token address to remove from favorites
     */
    function removeFavoriteToken(address token) external {
        address[] storage favorites = userFavoriteTokens[msg.sender];
        for (uint256 i = 0; i < favorites.length; i++) {
            if (favorites[i] == token) {
                // Replace with the last element and pop
                favorites[i] = favorites[favorites.length - 1];
                favorites.pop();
                break;
            }
        }
    }
    
    /**
     * @dev Adds a recipient to user's favorites
     * @param recipient Recipient address to add to favorites
     */
    function addFavoriteRecipient(address recipient) external {
        require(recipient != address(0), "Cannot add zero address to favorites");
        require(!blacklisted[recipient], "Cannot add blacklisted address to favorites");
        
        // Check if recipient already exists in favorites
        address[] storage favorites = userFavoriteRecipients[msg.sender];
        for (uint256 i = 0; i < favorites.length; i++) {
            if (favorites[i] == recipient) {
                return; // Already in favorites
            }
        }
        
        // Add to favorites (limit to 100 favorites)
        if (favorites.length < 100) {
            favorites.push(recipient);
        }
    }
    
    /**
     * @dev Removes a recipient from user's favorites
     * @param recipient Recipient address to remove from favorites
     */
    function removeFavoriteRecipient(address recipient) external {
        address[] storage favorites = userFavoriteRecipients[msg.sender];
        for (uint256 i = 0; i < favorites.length; i++) {
            if (favorites[i] == recipient) {
                // Replace with the last element and pop
                favorites[i] = favorites[favorites.length - 1];
                favorites.pop();
                break;
            }
        }
    }
    
    /**
     * @dev Get user's favorite tokens
     * @param user User address
     * @return favoriteTokens Array of favorite token addresses
     */
    function getUserFavoriteTokens(address user) external view returns (address[] memory favoriteTokens) {
        return userFavoriteTokens[user];
    }
    
    /**
     * @dev Get user's favorite recipients
     * @param user User address
     * @return favoriteRecipients Array of favorite recipient addresses
     */
    function getUserFavoriteRecipients(address user) external view returns (address[] memory favoriteRecipients) {
        return userFavoriteRecipients[user];
    }
    
    /**
     * @dev Get user's transaction history
     * @param user User address
     * @param startIndex Start index in history array
     * @param count Number of transactions to return
     * @return transactions Array of transactions
     */
    function getUserTransactionHistory(
        address user,
        uint256 startIndex,
        uint256 count
    ) external view returns (Transaction[] memory transactions) {
        Transaction[] storage history = userTransactionHistory[user];
        
        // Calculate actual count (don't exceed array bounds)
        uint256 availableCount = history.length > startIndex ? 
            history.length - startIndex : 0;
        uint256 actualCount = count < availableCount ? count : availableCount;
        
        // Create result array
        Transaction[] memory result = new Transaction[](actualCount);
        
        // Fill result array
        for (uint256 i = 0; i < actualCount; i++) {
            result[i] = history[startIndex + i];
        }
        
        return result;
    }
    
    /**
     * @dev Get transaction details by ID
     * @param transactionId Transaction ID
     * @return sender Address of the sender
     * @return transactionType Type of the transaction
     * @return timestamp Timestamp of the transaction
     * @return totalAmount Total amount involved in the transaction
     * @return recipientCount Number of recipients in the transaction
     * @return fee Fee associated with the transaction
     */
    function getTransactionDetails(bytes32 transactionId) external view returns (
        address sender,
        uint8 transactionType,
        uint256 timestamp,
        uint256 totalAmount,
        uint256 recipientCount,
        uint256 fee
    ) {
        TransactionDetails storage details = transactionDetails[transactionId];
        require(details.timestamp > 0, "Transaction not found");
        
        return (
            details.sender,
            details.transactionType,
            details.timestamp,
            details.totalAmount,
            details.recipientCount,
            details.fee
        );
    }
    
    /**
     * @dev Get token transfer history for a user
     * @param user User address
     * @param startIndex Start index in history array
     * @param count Number of transfers to return
     * @return transfers Array of token transfers
     */
    function getTokenTransferHistory(
        address user,
        uint256 startIndex,
        uint256 count
    ) external view returns (TokenTransferInfo[] memory transfers) {
        TokenTransferInfo[] storage history = tokenTransferHistory[user];
        
        // Calculate actual count (don't exceed array bounds)
        uint256 availableCount = history.length > startIndex ? 
            history.length - startIndex : 0;
        uint256 actualCount = count < availableCount ? count : availableCount;
        
        // Create result array
        TokenTransferInfo[] memory result = new TokenTransferInfo[](actualCount);
        
        // Fill result array
        for (uint256 i = 0; i < actualCount; i++) {
            result[i] = history[startIndex + i];
        }
        
        return result;
    }
    
    /**
     * @dev Get user statistics
     * @param user User address
     * @return transactionCount Total number of transactions executed by the user
     * @return totalVolumeNative Total volume of native currency transferred by the user
     * @return totalVolumeTokens Total volume of tokens transferred by the user
     * @return lastActiveTime Timestamp of the user's last activity
     * @return totalFeesPaid Total fees paid by the user
     * @return totalRecipientsServed Total number of recipients served by the user
     */
    function getUserStats(address user) external view returns (
        uint256 transactionCount,
        uint256 totalVolumeNative,
        uint256 totalVolumeTokens,
        uint256 lastActiveTime,
        uint256 totalFeesPaid,
        uint256 totalRecipientsServed
    ) {
        UserStats storage stats = userStats[user];
        
        return (
            stats.transactionCount,
            stats.totalVolumeNative,
            stats.totalVolumeTokens,
            stats.lastActiveTime,
            stats.totalFeesPaid,
            stats.totalRecipientsServed
        );
    }
    
    /**
     * @dev Set maximum history items per user
     * @param maxItems Maximum number of history items to store per user
     */
    function setMaxHistoryItemsPerUser(uint256 maxItems) external onlyOwner {
        require(maxItems > 0, "Max items must be greater than 0");
        require(maxItems <= 500, "Max items cannot exceed 500");
        maxHistoryItemsPerUser = maxItems;
    }
    
    /**
     * @dev Enable or disable gas refund program
     * @param enabled Whether gas refund program should be enabled
     * @param rate Gas refund rate in percentage (x100 for precision)
     */
    function setGasRefundProgram(bool enabled, uint256 rate) external onlyOwner {
        require(rate <= 10000, "Refund rate cannot exceed 100%");
        gasRefundProgramEnabled = enabled;
        gasRefundRate = rate;
    }
    
    /**
     * @dev Batch blacklist multiple addresses
     * @param recipients Array of addresses to blacklist
     */
    function batchBlacklistAddresses(address[] calldata recipients) external onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Cannot blacklist zero address");
            if (!blacklisted[recipients[i]]) {
                blacklisted[recipients[i]] = true;
                emit RecipientBlacklisted(recipients[i]);
            }
        }
    }
    
    /**
     * @dev Batch remove addresses from blacklist
     * @param recipients Array of addresses to remove from blacklist
     */
    function batchRemoveFromBlacklist(address[] calldata recipients) external onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            if (blacklisted[recipients[i]]) {
                blacklisted[recipients[i]] = false;
                emit RecipientRemovedFromBlacklist(recipients[i]);
            }
        }
    }
    
    /**
     * @dev Batch set address limits
     * @param recipients Array of recipient addresses
     * @param limits Array of limits for each recipient
     */
    function batchSetAddressLimits(
        address[] calldata recipients, 
        uint256[] calldata limits
    ) external onlyOwner {
        require(recipients.length == limits.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Cannot set limit for zero address");
            addressLimits[recipients[i]] = limits[i];
            emit AddressLimitSet(recipients[i], limits[i]);
        }
    }
    
    /**
     * @dev Emergency withdraw any stuck tokens (only owner)
     * @param token Token address (use zero address for native currency)
     */
    function emergencyWithdraw(address token) external onlyOwner {
        if (token == address(0)) {
            // Withdraw native currency
            uint256 balance = address(this).balance - accumulatedFees;
            require(balance > 0, "No native currency to withdraw");
            
            (bool success, ) = msg.sender.call{value: balance}("");
            require(success, "Native currency withdrawal failed");
        } else {
            // Withdraw tokens
            IERC20Minimal tokenContract = IERC20Minimal(token);
            uint256 balance = tokenContract.balanceOf(address(this));
            require(balance > 0, "No tokens to withdraw");
            
            SafeERC20.safeTransfer(tokenContract, msg.sender, balance);
        }
    }
    
    /**
     * @dev Allows the contract to receive native currency
     */
    receive() external payable {}
}

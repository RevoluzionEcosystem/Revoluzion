/*

██████  ███████ ██    ██  ██████  ██      ██    ██ ███████ ██  ██████  ███    ██                   
██   ██ ██      ██    ██ ██    ██ ██      ██    ██     ██  ██ ██    ██ ████   ██                  
██████  █████   ██    ██ ██    ██ ██      ██    ██   ██    ██ ██    ██ ██ ██  ██                   
██   ██ ██       ██  ██  ██    ██ ██      ██    ██  ██     ██ ██    ██ ██  ██ ██                   
██   ██ ███████   ████    ██████  ███████  ██████  ███████ ██  ██████  ██   ████              

Revoluzion Ecosystem
https://revoluzion.app

Revoluzion Migrator - Token Migration smart contract for project owners to migrate their tokens to a new token address with a conversion rate.
Modified: Fees are only charged to project owners when creating migrations, not to users during migration.

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title IERC20 Interface
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title Address Library
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     */
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     */
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {functionCall}, but with `errorMessage` as a fallback revert reason when `target` reverts.
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {functionCall}, but also transferring `value` wei to `target`.
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {functionCallWithValue}, but with `errorMessage` as a fallback revert reason
     * when `target` reverts.
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't,
     * either by bubbling up the revert reason or using the provided `errorMessage`.
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

/**
 * @dev Context contract used for Ownable
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Ownable contract for access control
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
 * @title Pausable
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 */
abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

/**
 * @title MigrationMetadata
 * @dev Struct for storing additional information about migrations
 */
struct MigrationMetadata {
    string name; // Name of the migration project
    string description; // Description of the migration
    string logoURI; // Logo URI for frontend display
    uint256 createdAt; // Timestamp when the migration was created
    string websiteURL; // Project website URL
    string socialURL; // Social media URL
}

/**
 * @title UserActivity
 * @dev Struct for tracking user activity
 */
struct UserActivity {
    uint256 lastActiveTime; // Last time user interacted with the contract
    uint256 totalTransactions; // Total number of transactions by the user
    uint256 totalMigrations; // Total number of token migrations by the user
    uint256 totalValueMigrated; // Total value migrated (in old token units)
}

/**
 * @title Transaction
 * @dev Struct for tracking user transactions
 */
struct Transaction {
    bytes32 transactionId;
    uint8 transactionType;
    uint256 timestamp;
    uint256 amount;
}

/**
 * @title MigrationArchive
 * @dev Struct for archiving previous migrations
 */
struct MigrationArchive {
    address projectOwner;
    address oldToken;
    address newToken;
    uint256 totalMigrated;
    uint256 timestamp;
}

/**
 * @title RevoluzionMigrator
 * @dev Contract for token migration with improved security, tracking, and frontend integration
 * Modified to only charge fees to project owners when creating migrations, not to users
 */
contract RevoluzionMigrator is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // Custom errors for gas optimization
    error InvalidTokenAddress();
    error InvalidProjectOwnerAddress();
    error NotAuthorizedProjectOwner();
    error MigrationDoesNotExist();
    error MigrationInactive();
    error MigrationExpired();
    error RateLimitExceeded();
    error AmountTooLow();
    error InsufficientFee();
    error TokenDecimalsTooHigh();
    error NameTooLong();
    error DescriptionTooLong();
    error LogoURITooLong();
    error WebsiteURLTooLong();
    error SocialURLTooLong();
    error InsufficientBalance();
    error CannotWithdrawUserDeposits();
    error TimelockAlreadyInitiated();
    error TimelockNotInitiated();
    error OperationTimelocked();
    error FeeRecipientNotSet();
    error NoFeesCollected();
    error ArrayLengthMismatch();
    error TransactionExpired();
    error OldTokenNotWhitelisted();
    error NewTokenNotWhitelisted();
    error TokenNotContract(address token);

    // Fee denominator for percentage calculations (10000 = 100%)
    uint256 private constant FEE_DENOMINATOR = 10000;

    // Fixed fee amount for migration creation (can be adjusted by the owner)
    uint256 public migrationCreationFee;

    // Time constants
    uint256 private constant SECONDS_PER_DAY = 86400;
    uint256 private constant SECONDS_PER_HOUR = 3600;

    // Maximum length for string metadata fields
    uint256 private constant MAX_NAME_LENGTH = 100;
    uint256 private constant MAX_DESCRIPTION_LENGTH = 500;
    uint256 private constant MAX_URL_LENGTH = 200;

    // Transaction types
    uint8 private constant TX_TYPE_DEPOSIT = 0;
    uint8 private constant TX_TYPE_MIGRATION = 1;

    /**
     * @dev Optimized Migration struct with better packing for gas efficiency
     */
    struct Migration {
        // Slot 1
        address oldToken; // 20 bytes
        uint8 oldTokenDecimals; // 1 byte
        uint8 newTokenDecimals; // 1 byte
        bool active; // 1 byte
        // 9 bytes remaining in slot 1

        // Slot 2
        address newToken; // 20 bytes
        // 12 bytes remaining in slot 2

        // Slot 3+
        uint256 rate; // 32 bytes (full slot)
        uint256 totalMigrated; // 32 bytes (full slot)
        uint256 expiryTime; // 32 bytes (full slot)
        MigrationMetadata metadata; // multiple slots
    }

    // Archive of previous migrations
    MigrationArchive[] public archivedMigrations;

    // Fee recipient address
    address public feeRecipient;

    // Mapping from project owner to their migration configuration
    mapping(address => Migration) public migrations;

    // Array to track all project owners for iteration
    address[] private projectOwnersList;
    mapping(address => uint256) private projectOwnerIndices;

    // Mapping from user to token to amount deposited
    mapping(address => mapping(address => uint256)) public userDeposits;

    // Mapping to track all users who have deposited a specific token
    mapping(address => address[]) private tokenDepositorsList;
    mapping(address => mapping(address => bool)) private tokenDepositors;

    // Mapping to track if an address is an authorized project owner
    mapping(address => bool) public authorizedProjectOwners;

    // Whitelisted tokens that can be migrated (if empty, all tokens are allowed)
    mapping(address => bool) public whitelistedTokens;

    // Whether token whitelist is enabled
    bool public whitelistEnabled;

    // Track fees collected in native currency
    uint256 public totalFeesCollected;

    // Track global statistics
    uint256 public totalMigrationsCreated;
    uint256 public totalTokensMigrated;
    uint256 public totalUniqueUsers;
    uint256 public totalTransactionsCount;

    // Track user activity
    mapping(address => UserActivity) public userActivities;

    // Track daily volumes for analytics
    mapping(uint256 => uint256) public dailyMigrationVolume; // timestamp/86400 => volume

    // Emergency timelock for parameter changes
    uint256 public constant TIMELOCK_DURATION = 2 days;
    mapping(bytes32 => uint256) public timelockExpiries;

    // Rate limit for migrations
    mapping(address => uint256) public lastMigrationTimestamp;
    uint256 public constant RATE_LIMIT_PERIOD = 1 hours;

    // Track user transaction history
    mapping(address => Transaction[]) private userTransactionHistory;

    // Events
    event MigrationCreated(
        address indexed projectOwner,
        address indexed oldToken,
        address indexed newToken,
        uint256 rate,
        uint256 expiryTime,
        string name,
        uint256 feeAmount
    );

    event TokensDeposited(
        address indexed user,
        address indexed projectOwner,
        address indexed oldToken,
        uint256 amount,
        uint256 totalDeposited
    );

    event TokensMigrated(
        address indexed user,
        address indexed projectOwner,
        address indexed newToken,
        uint256 oldAmount,
        uint256 newAmount
    );

    event TokensWithdrawn(
        address indexed projectOwner,
        address indexed token,
        uint256 amount
    );

    event FeeCollected(
        address indexed projectOwner,
        uint256 amount,
        uint256 totalCollected
    );

    event MigrationUpdated(
        address indexed projectOwner,
        uint256 newRate,
        uint256 newExpiryTime
    );

    event MigrationStatusChanged(address indexed projectOwner, bool active);

    event ProjectOwnerAuthorized(address indexed projectOwner, bool authorized);

    event TokenWhitelistUpdated(address indexed token, bool whitelisted);

    event WhitelistStatusChanged(bool enabled);

    event NativeCurrencyWithdrawn(address indexed receiver, uint256 amount);

    event TimelockInitiated(bytes32 indexed operationId, uint256 executeAfter);

    event TimelockExecuted(bytes32 indexed operationId);

    event TimelockCancelled(bytes32 indexed operationId);

    event EmergencyPause(bool paused);

    event MigrationMetadataUpdated(
        address indexed projectOwner,
        string name,
        string description
    );

    event FeeRecipientSet(address indexed recipient);

    event MigrationArchived(
        address indexed projectOwner,
        address indexed oldToken,
        address indexed newToken,
        uint256 totalMigrated
    );

    event FeesWithdrawn(
        address indexed recipient,
        uint256 amount
    );

    event MigrationCreationFeeUpdated(uint256 oldFee, uint256 newFee);

    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    // Modifiers
    modifier onlyProjectOwner() {
        if (
            !authorizedProjectOwners[msg.sender] ||
            migrations[msg.sender].oldToken == address(0)
        ) {
            revert NotAuthorizedProjectOwner();
        }
        _;
    }

    modifier migrationExists(address projectOwner) {
        if (migrations[projectOwner].oldToken == address(0)) {
            revert MigrationDoesNotExist();
        }
        _;
    }

    modifier migrationActive(address projectOwner) {
        Migration storage migration = migrations[projectOwner];
        if (!migration.active) {
            revert MigrationInactive();
        }

        if (
            migration.expiryTime > 0 && block.timestamp > migration.expiryTime
        ) {
            revert MigrationExpired();
        }

        _;
    }

    modifier whenNotTimelocked(bytes32 operationId) {
        if (
            timelockExpiries[operationId] != 0 &&
            block.timestamp < timelockExpiries[operationId]
        ) {
            revert OperationTimelocked();
        }
        _;
    }

    modifier rateLimited() {
        if (
            lastMigrationTimestamp[msg.sender] != 0 &&
            block.timestamp <
            lastMigrationTimestamp[msg.sender] + RATE_LIMIT_PERIOD
        ) {
            revert RateLimitExceeded();
        }
        _;
    }

    modifier updateUserActivity() {
        UserActivity storage activity = userActivities[msg.sender];
        activity.lastActiveTime = block.timestamp;
        activity.totalTransactions++;

        // If this is a new user, increment unique users count
        if (activity.totalTransactions == 1) {
            totalUniqueUsers++;
        }

        totalTransactionsCount++;
        _;
    }

    /**
     * @dev Constructor for the RevoluzionMigrator contract
     * @param _initialFee Initial fee for migration creation in native currency
     * @param _feeRecipient Address that will receive fees
     */
    constructor(uint256 _initialFee, address _feeRecipient) {
        if (_feeRecipient == address(0)) {
            revert InvalidTokenAddress();
        }
        migrationCreationFee = _initialFee;
        feeRecipient = _feeRecipient;
    }

    /**
     * @dev Sets the fee recipient address
     * @param _feeRecipient Address that will receive fees
     */
    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        if (_feeRecipient == address(0)) {
            revert InvalidTokenAddress();
        }
        feeRecipient = _feeRecipient;
        emit FeeRecipientSet(_feeRecipient);
    }

    /**
     * @dev Updates the migration creation fee
     * @param _newFee New fee amount in native currency
     */
    function updateMigrationCreationFee(uint256 _newFee) external onlyOwner {
        uint256 oldFee = migrationCreationFee;
        migrationCreationFee = _newFee;
        emit MigrationCreationFeeUpdated(oldFee, _newFee);
    }

    /**
     * @dev Emergency pause/unpause function
     * @param _paused Whether to pause or unpause the contract
     */
    function setEmergencyPause(bool _paused) external onlyOwner {
        if (_paused) {
            _pause();
        } else {
            _unpause();
        }
        emit EmergencyPause(_paused);
    }

    /**
     * @dev Emergency pause for individual migrations
     * @param _projectOwner Address of the project owner whose migration should be paused
     */
    function emergencyPauseMigration(address _projectOwner) external onlyOwner {
        if (migrations[_projectOwner].oldToken == address(0)) {
            revert MigrationDoesNotExist();
        }
        migrations[_projectOwner].active = false;
        emit MigrationStatusChanged(_projectOwner, false);
    }

    /**
     * @dev Initiates a timelock for a sensitive operation
     * @param _operationId Unique identifier for the operation
     */
    function initiateTimelock(bytes32 _operationId) external onlyOwner {
        if (timelockExpiries[_operationId] != 0) {
            revert TimelockAlreadyInitiated();
        }

        timelockExpiries[_operationId] = block.timestamp + TIMELOCK_DURATION;
        emit TimelockInitiated(_operationId, timelockExpiries[_operationId]);
    }

    /**
     * @dev Cancels a timelock for a sensitive operation
     * @param _operationId Unique identifier for the operation
     */
    function cancelTimelock(bytes32 _operationId) external onlyOwner {
        if (timelockExpiries[_operationId] == 0) {
            revert TimelockNotInitiated();
        }

        delete timelockExpiries[_operationId];
        emit TimelockCancelled(_operationId);
    }

    /**
     * @dev Execute a timelocked operation
     * @param _operationId Unique identifier for the operation
     */
    function executeTimelock(
        bytes32 _operationId
    ) external onlyOwner whenNotTimelocked(_operationId) {
        if (timelockExpiries[_operationId] == 0) {
            revert TimelockNotInitiated();
        }

        delete timelockExpiries[_operationId];
        emit TimelockExecuted(_operationId);
        // Actual execution happens in the specific functions that use whenNotTimelocked
    }

    /**
     * @dev Authorizes a project owner to create migrations
     * @param _projectOwner Address to authorize
     * @param _authorized Whether to authorize or revoke authorization
     */
    function authorizeProjectOwner(
        address _projectOwner,
        bool _authorized
    ) external onlyOwner whenNotPaused {
        if (_projectOwner == address(0)) {
            revert InvalidProjectOwnerAddress();
        }

        // Update authorization status
        authorizedProjectOwners[_projectOwner] = _authorized;

        // If newly authorized, add to list (if not already there)
        if (_authorized && projectOwnerIndices[_projectOwner] == 0) {
            projectOwnersList.push(_projectOwner);
            projectOwnerIndices[_projectOwner] = projectOwnersList.length;
        }

        // If revoking and they have no active migration, remove from list
        if (!_authorized && migrations[_projectOwner].oldToken == address(0)) {
            _removeProjectOwner(_projectOwner);
        }

        emit ProjectOwnerAuthorized(_projectOwner, _authorized);
    }

    /**
     * @dev Removes a project owner from the list
     * @param _owner Address to remove
     */
    function _removeProjectOwner(address _owner) internal {
        uint256 index = projectOwnerIndices[_owner];
        if (index > 0) {
            // Index is stored +1 to distinguish from default value 0
            index--;

            // Move the last element to the deleted spot
            address lastOwner = projectOwnersList[projectOwnersList.length - 1];
            projectOwnersList[index] = lastOwner;
            projectOwnerIndices[lastOwner] = index + 1;

            // Delete the last element
            projectOwnersList.pop();
            delete projectOwnerIndices[_owner];
        }
    }

    /**
     * @dev Updates token whitelist
     * @param _token Token address
     * @param _whitelisted Whether to whitelist or de-whitelist the token
     */
    function updateTokenWhitelist(
        address _token,
        bool _whitelisted
    ) external onlyOwner whenNotPaused {
        if (_token == address(0)) {
            revert InvalidTokenAddress();
        }

        whitelistedTokens[_token] = _whitelisted;
        emit TokenWhitelistUpdated(_token, _whitelisted);
    }

    /**
     * @dev Enables or disables token whitelist
     * @param _enabled Whether to enable whitelist
     */
    function setWhitelistEnabled(
        bool _enabled
    ) external onlyOwner whenNotPaused {
        whitelistEnabled = _enabled;
        emit WhitelistStatusChanged(_enabled);
    }

    /**
     * @dev Safely gets token decimals with fallback to 18 if call fails
     * @param _token Token address
     * @return decimals Token decimal places
     */
    function _safeGetDecimals(
        address _token
    ) internal view returns (uint8 decimals) {
        try IERC20(_token).decimals() returns (uint8 _decimals) {
            return _decimals;
        } catch {
            // Try another common approach
            (bool success, bytes memory data) = _token.staticcall(
                abi.encodeWithSignature("decimals()")
            );
            if (success && data.length >= 32) {
                return uint8(uint256(bytes32(data)));
            }

            // Default to 18 if all attempts fail
            return 18;
        }
    }

    /**
     * @dev Internal helper function to create a migration with all parameters
     * @param _oldToken Address of the token to migrate from
     * @param _newToken Address of the token to migrate to
     * @param _rate Conversion rate in basis points (10000 = 1:1)
     * @param _expiryTime Timestamp when migration expires (0 = no expiry)
     * @param _name Name of the migration project
     * @param _description Description of the migration
     * @param _logoURI Logo URI for frontend display
     * @param _websiteURL Project website URL
     * @param _socialURL Social media URL
     * @param _deadline Block timestamp after which this transaction is invalid (0 = no deadline)
     */
    function _createMigrationInternal(
        address _oldToken,
        address _newToken,
        uint256 _rate,
        uint256 _expiryTime,
        string memory _name,
        string memory _description,
        string memory _logoURI,
        string memory _websiteURL,
        string memory _socialURL,
        uint256 _deadline
    ) internal {
        // Front-running protection
        if (_deadline > 0 && block.timestamp > _deadline) {
            revert TransactionExpired();
        }

        if (!authorizedProjectOwners[msg.sender]) {
            revert NotAuthorizedProjectOwner();
        }

        if (_oldToken == address(0) || _newToken == address(0)) {
            revert InvalidTokenAddress();
        }

        if (_rate == 0) {
            revert AmountTooLow();
        }

        // Ensure the project owner has paid the required fee
        if (msg.value < migrationCreationFee) {
            revert InsufficientFee();
        }

        // Process fee payment
        if (migrationCreationFee > 0) {
            totalFeesCollected += msg.value;
            emit FeeCollected(msg.sender, msg.value, totalFeesCollected);
        }

        // Add input validation for metadata
        if (bytes(_name).length > MAX_NAME_LENGTH) {
            revert NameTooLong();
        }

        if (bytes(_description).length > MAX_DESCRIPTION_LENGTH) {
            revert DescriptionTooLong();
        }

        if (bytes(_logoURI).length > MAX_URL_LENGTH) {
            revert LogoURITooLong();
        }

        if (bytes(_websiteURL).length > MAX_URL_LENGTH) {
            revert WebsiteURLTooLong();
        }

        if (bytes(_socialURL).length > MAX_URL_LENGTH) {
            revert SocialURLTooLong();
        }

        // Check if tokens are whitelisted if whitelist is enabled
        if (whitelistEnabled) {
            // Replace string errors with custom errors for gas optimization
            if (!whitelistedTokens[_oldToken]) {
                revert OldTokenNotWhitelisted();
            }
            if (!whitelistedTokens[_newToken]) {
                revert NewTokenNotWhitelisted();
            }
        }

        // Verify tokens implement the ERC20 interface
        if (!Address.isContract(_oldToken)) {
            revert TokenNotContract(_oldToken);
        }
        if (!Address.isContract(_newToken)) {
            revert TokenNotContract(_newToken);
        }

        // Get token decimals safely
        uint8 oldTokenDecimals = _safeGetDecimals(_oldToken);
        uint8 newTokenDecimals = _safeGetDecimals(_newToken);

        // Limit maximum decimals to prevent overflow
        if (oldTokenDecimals > 30 || newTokenDecimals > 30) {
            revert TokenDecimalsTooHigh();
        }

        // Check if this project owner already has a migration and update instead
        if (migrations[msg.sender].oldToken != address(0)) {
            Migration storage migration = migrations[msg.sender];

            // Archive the old migration if tokens are changing
            if (
                migration.oldToken != _oldToken ||
                migration.newToken != _newToken
            ) {
                archivedMigrations.push(
                    MigrationArchive({
                        projectOwner: msg.sender,
                        oldToken: migration.oldToken,
                        newToken: migration.newToken,
                        totalMigrated: migration.totalMigrated,
                        timestamp: block.timestamp
                    })
                );

                emit MigrationArchived(
                    msg.sender,
                    migration.oldToken,
                    migration.newToken,
                    migration.totalMigrated
                );

                migration.totalMigrated = 0; // Reset only if tokens changed
            }

            migration.oldToken = _oldToken;
            migration.newToken = _newToken;
            migration.rate = _rate;
            migration.expiryTime = _expiryTime;
            migration.oldTokenDecimals = oldTokenDecimals;
            migration.newTokenDecimals = newTokenDecimals;
            migration.active = true;

            // Update metadata
            migration.metadata.name = _name;
            migration.metadata.description = _description;
            migration.metadata.logoURI = _logoURI;
            migration.metadata.websiteURL = _websiteURL;
            migration.metadata.socialURL = _socialURL;
        } else {
            // Create new migration
            migrations[msg.sender] = Migration({
                oldToken: _oldToken,
                newToken: _newToken,
                rate: _rate,
                totalMigrated: 0,
                expiryTime: _expiryTime,
                oldTokenDecimals: oldTokenDecimals,
                newTokenDecimals: newTokenDecimals,
                active: true,
                metadata: MigrationMetadata({
                    name: _name,
                    description: _description,
                    logoURI: _logoURI,
                    createdAt: block.timestamp,
                    websiteURL: _websiteURL,
                    socialURL: _socialURL
                })
            });

            // Add to list of project owners if not already there
            if (projectOwnerIndices[msg.sender] == 0) {
                projectOwnersList.push(msg.sender);
                projectOwnerIndices[msg.sender] = projectOwnersList.length;
            }

            // Increment total migrations created
            totalMigrationsCreated++;
        }

        emit MigrationCreated(
            msg.sender,
            _oldToken,
            _newToken,
            _rate,
            _expiryTime,
            _name,
            msg.value
        );
    }

    /**
     * @dev Creates a new migration with metadata and deadline for front-running protection
     * @param _oldToken Address of the token to migrate from
     * @param _newToken Address of the token to migrate to
     * @param _rate Conversion rate in basis points (10000 = 1:1)
     * @param _expiryTime Timestamp when migration expires (0 = no expiry)
     * @param _name Name of the migration project
     * @param _description Description of the migration
     * @param _logoURI Logo URI for frontend display
     * @param _websiteURL Project website URL
     * @param _socialURL Social media URL
     * @param _deadline Block timestamp after which this transaction is invalid (0 = no deadline)
     */
    function createMigrationWithDeadline(
        address _oldToken,
        address _newToken,
        uint256 _rate,
        uint256 _expiryTime,
        string memory _name,
        string memory _description,
        string memory _logoURI,
        string memory _websiteURL,
        string memory _socialURL,
        uint256 _deadline
    ) external payable whenNotPaused updateUserActivity {
        _createMigrationInternal(
            _oldToken,
            _newToken,
            _rate,
            _expiryTime,
            _name,
            _description,
            _logoURI,
            _websiteURL,
            _socialURL,
            _deadline
        );
    }

    /**
     * @dev Simpler version of createMigration without deadline
     */
    function createMigration(
        address _oldToken,
        address _newToken,
        uint256 _rate,
        uint256 _expiryTime,
        string memory _name,
        string memory _description,
        string memory _logoURI,
        string memory _websiteURL,
        string memory _socialURL
    ) external payable whenNotPaused updateUserActivity {
        _createMigrationInternal(
            _oldToken,
            _newToken,
            _rate,
            _expiryTime,
            _name,
            _description,
            _logoURI,
            _websiteURL,
            _socialURL,
            0 // No deadline
        );
    }

    /**
     * @dev Updates migration parameters
     * @param _rate New conversion rate
     * @param _expiryTime New expiry time
     */
    function updateMigration(
        uint256 _rate,
        uint256 _expiryTime
    ) external onlyProjectOwner whenNotPaused updateUserActivity {
        if (_rate == 0) {
            revert AmountTooLow();
        }

        Migration storage migration = migrations[msg.sender];

        migration.rate = _rate;
        migration.expiryTime = _expiryTime;

        emit MigrationUpdated(msg.sender, _rate, _expiryTime);
    }

    /**
     * @dev Updates migration metadata
     * @param _name New name
     * @param _description New description
     * @param _logoURI New logo URI
     * @param _websiteURL New website URL
     * @param _socialURL New social media URL
     */
    function updateMigrationMetadata(
        string memory _name,
        string memory _description,
        string memory _logoURI,
        string memory _websiteURL,
        string memory _socialURL
    ) external onlyProjectOwner whenNotPaused updateUserActivity {
        // Add input validation
        if (bytes(_name).length > MAX_NAME_LENGTH) {
            revert NameTooLong();
        }

        if (bytes(_description).length > MAX_DESCRIPTION_LENGTH) {
            revert DescriptionTooLong();
        }

        if (bytes(_logoURI).length > MAX_URL_LENGTH) {
            revert LogoURITooLong();
        }

        if (bytes(_websiteURL).length > MAX_URL_LENGTH) {
            revert WebsiteURLTooLong();
        }

        if (bytes(_socialURL).length > MAX_URL_LENGTH) {
            revert SocialURLTooLong();
        }

        Migration storage migration = migrations[msg.sender];

        migration.metadata.name = _name;
        migration.metadata.description = _description;
        migration.metadata.logoURI = _logoURI;
        migration.metadata.websiteURL = _websiteURL;
        migration.metadata.socialURL = _socialURL;

        emit MigrationMetadataUpdated(msg.sender, _name, _description);
    }

    /**
     * @dev Activates or deactivates a migration
     * @param _active Whether to activate or deactivate
     */
    function setMigrationActive(
        bool _active
    ) external onlyProjectOwner whenNotPaused updateUserActivity {
        migrations[msg.sender].active = _active;
        emit MigrationStatusChanged(msg.sender, _active);
    }

    /**
     * @dev Deposits old tokens for migration
     * @param _projectOwner Address of the project owner
     * @param _amount Amount of tokens to deposit
     */
    function depositTokens(
        address _projectOwner,
        uint256 _amount
    )
        external
        nonReentrant
        whenNotPaused
        migrationExists(_projectOwner)
        migrationActive(_projectOwner)
        updateUserActivity
    {
        if (_amount == 0) {
            revert AmountTooLow();
        }

        Migration storage migration = migrations[_projectOwner];

        // Transfer tokens from user to contract
        IERC20(migration.oldToken).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        // Update user deposit - Removed unused variable declaration
        userDeposits[msg.sender][migration.oldToken] += _amount;

        // Add user to token depositors list if not already there
        if (!tokenDepositors[migration.oldToken][msg.sender]) {
            tokenDepositorsList[migration.oldToken].push(msg.sender);
            tokenDepositors[migration.oldToken][msg.sender] = true;
        }

        // Record this transaction in history
        _recordTransaction(msg.sender, TX_TYPE_DEPOSIT, _amount);

        emit TokensDeposited(
            msg.sender,
            _projectOwner,
            migration.oldToken,
            _amount,
            userDeposits[msg.sender][migration.oldToken]
        );
    }

    /**
     * @dev Deposits tokens for multiple projects at once
     * @param _projectOwners Array of project owner addresses
     * @param _amounts Array of amounts to deposit
     */
    function batchDepositTokens(
        address[] calldata _projectOwners,
        uint256[] calldata _amounts
    ) external nonReentrant whenNotPaused updateUserActivity {
        if (_projectOwners.length != _amounts.length) {
            revert ArrayLengthMismatch();
        }

        if (_projectOwners.length == 0) {
            revert AmountTooLow();
        }

        for (uint256 i = 0; i < _projectOwners.length; ) {
            address projectOwner = _projectOwners[i];
            uint256 amount = _amounts[i];

            if (migrations[projectOwner].oldToken == address(0)) {
                revert MigrationDoesNotExist();
            }

            if (!migrations[projectOwner].active) {
                revert MigrationInactive();
            }

            if (
                migrations[projectOwner].expiryTime > 0 &&
                block.timestamp > migrations[projectOwner].expiryTime
            ) {
                revert MigrationExpired();
            }

            if (amount == 0) {
                revert AmountTooLow();
            }

            Migration storage migration = migrations[projectOwner];

            // Transfer tokens
            IERC20(migration.oldToken).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );

            // Update user deposit
            userDeposits[msg.sender][migration.oldToken] += amount;

            // Add user to token depositors list if not already there
            if (!tokenDepositors[migration.oldToken][msg.sender]) {
                tokenDepositorsList[migration.oldToken].push(msg.sender);
                tokenDepositors[migration.oldToken][msg.sender] = true;
            }

            // Record transaction
            _recordTransaction(msg.sender, TX_TYPE_DEPOSIT, amount);

            emit TokensDeposited(
                msg.sender,
                projectOwner,
                migration.oldToken,
                amount,
                userDeposits[msg.sender][migration.oldToken]
            );

            // Gas optimization using unchecked
            unchecked {
                i++;
            }
        }
    }

    /**
     * @dev Migrates tokens from old to new based on conversion rate
     * @param _projectOwner Address of the project owner
     */
    function migrateTokens(
        address _projectOwner
    )
        external
        nonReentrant
        whenNotPaused
        migrationExists(_projectOwner)
        migrationActive(_projectOwner)
        rateLimited
        updateUserActivity
    {
        // Using storage instead of memory to ensure state updates are persisted
        Migration storage migration = migrations[_projectOwner];

        uint256 depositAmount = userDeposits[msg.sender][migration.oldToken];
        if (depositAmount == 0) {
            revert AmountTooLow();
        }

        // Reset user deposit before external calls (reentrancy protection)
        userDeposits[msg.sender][migration.oldToken] = 0;

        // Update total migrated - Changes will now be saved to storage
        migration.totalMigrated += depositAmount;
        totalTokensMigrated += depositAmount;

        // Update user migration activity
        userActivities[msg.sender].totalMigrations++;
        userActivities[msg.sender].totalValueMigrated += depositAmount;

        // Update daily migration volume
        uint256 today = block.timestamp / SECONDS_PER_DAY;
        dailyMigrationVolume[today] += depositAmount;

        // Update rate limiting timestamp
        lastMigrationTimestamp[msg.sender] = block.timestamp;

        // Calculate converted amount with decimal adjustment
        uint256 convertedAmount;
        if (migration.oldTokenDecimals == migration.newTokenDecimals) {
            // Same decimals, use rate directly
            convertedAmount =
                (depositAmount * migration.rate) /
                FEE_DENOMINATOR;
        } else if (migration.oldTokenDecimals < migration.newTokenDecimals) {
            // New token has more decimals, adjust upward
            uint256 decimalsDiff = migration.newTokenDecimals -
                migration.oldTokenDecimals;
            // Fix: Reorder operations to avoid precision loss
            convertedAmount =
                (depositAmount * migration.rate * (10 ** decimalsDiff)) /
                FEE_DENOMINATOR;
        } else {
            // Old token has more decimals, adjust downward
            uint256 decimalsDiff = migration.oldTokenDecimals -
                migration.newTokenDecimals;
            // Fix: Reorder operations to avoid precision loss
            convertedAmount =
                (depositAmount * migration.rate) /
                FEE_DENOMINATOR /
                (10 ** decimalsDiff);
        }

        // Record this transaction in history
        _recordTransaction(msg.sender, TX_TYPE_MIGRATION, depositAmount);

        // Transfer new tokens to user - no fee taken
        IERC20(migration.newToken).safeTransfer(msg.sender, convertedAmount);

        emit TokensMigrated(
            msg.sender,
            _projectOwner,
            migration.newToken,
            depositAmount,
            convertedAmount
        );
    }

    /**
     * @dev Records transaction history
     * @param _user User address
     * @param _transactionType Type of transaction (0=deposit, 1=migration)
     * @param _amount Amount of tokens
     */
    function _recordTransaction(
        address _user,
        uint8 _transactionType,
        uint256 _amount
    ) internal {
        bytes32 txId = keccak256(
            abi.encodePacked(_user, block.timestamp, _transactionType, _amount)
        );
        userTransactionHistory[_user].push(
            Transaction({
                transactionId: txId,
                transactionType: _transactionType,
                timestamp: block.timestamp,
                amount: _amount
            })
        );
    }

    /**
     * @dev Allows project owner to withdraw tokens with safety limits
     * @param _token Address of the token to withdraw
     * @param _amount Amount to withdraw
     */
    function withdrawTokens(
        address _token,
        uint256 _amount
    ) external nonReentrant whenNotPaused onlyProjectOwner updateUserActivity {
        if (_token == address(0)) {
            revert InvalidTokenAddress();
        }

        if (_amount == 0) {
            revert AmountTooLow();
        }

        Migration storage migration = migrations[msg.sender];

        // If withdrawing the old token, ensure we don't withdraw user deposits
        if (_token == migration.oldToken) {
            uint256 availableBalance = IERC20(_token).balanceOf(address(this));
            uint256 totalDeposits = getTotalDepositsForToken(_token);

            if (availableBalance < totalDeposits + _amount) {
                revert CannotWithdrawUserDeposits();
            }
        }

        // Transfer tokens to project owner
        IERC20(_token).safeTransfer(msg.sender, _amount);

        emit TokensWithdrawn(msg.sender, _token, _amount);
    }

    /**
     * @dev Withdraws collected fees to the fee recipient
     */
    function withdrawCollectedFees() external nonReentrant onlyOwner {
        if (feeRecipient == address(0)) {
            revert FeeRecipientNotSet();
        }

        uint256 feeAmount = totalFeesCollected;
        if (feeAmount == 0) {
            revert NoFeesCollected();
        }

        // Reset fee tracking before transfer
        totalFeesCollected = 0;

        // Transfer fees to fee recipient
        payable(feeRecipient).transfer(feeAmount);

        emit FeesWithdrawn(feeRecipient, feeAmount);
    }

    /**
     * @dev Allows the contract owner to withdraw any accidentally sent native currency
     * @param _amount Amount to withdraw (0 for all)
     */
    function withdrawNativeCurrency(
        uint256 _amount
    ) external nonReentrant onlyOwner {
        // Ensure we don't withdraw collected fees
        uint256 availableBalance = address(this).balance - totalFeesCollected;
        
        if (availableBalance == 0) {
            revert AmountTooLow();
        }

        uint256 amountToWithdraw = _amount == 0 ? availableBalance : _amount;
        if (amountToWithdraw > availableBalance) {
            revert InsufficientBalance();
        }

        payable(owner()).transfer(amountToWithdraw);

        emit NativeCurrencyWithdrawn(owner(), amountToWithdraw);
    }

    /**
     * @dev Calculates the total deposits for a specific token across all users
     * @param _token Token address
     * @return totalDeposits Total deposits for the token
     */
    function getTotalDepositsForToken(
        address _token
    ) public view returns (uint256 totalDeposits) {
        address[] memory depositors = tokenDepositorsList[_token];

        for (uint256 i = 0; i < depositors.length; ) {
            totalDeposits += userDeposits[depositors[i]][_token];

            // Gas optimization
            unchecked {
                i++;
            }
        }

        return totalDeposits;
    }

    /**
     * @dev Gets a project owner at a specific index
     * @param _index Index to query
     * @return Project owner address
     */
    function getProjectOwnerAtIndex(
        uint256 _index
    ) public view returns (address) {
        if (_index >= projectOwnersList.length) {
            return address(0);
        }
        return projectOwnersList[_index];
    }

    /**
     * @dev Gets the total number of project owners
     * @return Total number of project owners
     */
    function getProjectOwnersCount() public view returns (uint256) {
        return projectOwnersList.length;
    }

    /**
     * @dev Gets all project owners (paginated)
     * @param _offset Starting index
     * @param _limit Maximum number of items to return
     * @return Array of project owner addresses
     */
    function getProjectOwners(
        uint256 _offset,
        uint256 _limit
    ) external view returns (address[] memory) {
        if (_offset >= projectOwnersList.length) {
            return new address[](0);
        }

        uint256 end = _offset + _limit;
        if (end > projectOwnersList.length) {
            end = projectOwnersList.length;
        }

        uint256 length = end - _offset;
        address[] memory result = new address[](length);

        for (uint256 i = 0; i < length; ) {
            result[i] = projectOwnersList[_offset + i];

            // Gas optimization
            unchecked {
                i++;
            }
        }

        return result;
    }

    /**
     * @dev Gets active project owners (paginated)
     * @param _offset Starting index
     * @param _limit Maximum number of items to return
     * @return Active project owner addresses
     */
    function getActiveProjectOwners(
        uint256 _offset,
        uint256 _limit
    ) external view returns (address[] memory) {
        // Count active owners first
        uint256 activeCount = 0;
        for (uint256 i = 0; i < projectOwnersList.length; ) {
            address owner = projectOwnersList[i];
            Migration storage migration = migrations[owner];
            if (
                migration.active &&
                (migration.expiryTime == 0 ||
                    block.timestamp <= migration.expiryTime)
            ) {
                activeCount++;
            }

            // Gas optimization
            unchecked {
                i++;
            }
        }

        if (_offset >= activeCount) {
            return new address[](0);
        }

        uint256 end = _offset + _limit;
        if (end > activeCount) {
            end = activeCount;
        }

        uint256 length = end - _offset;
        address[] memory result = new address[](length);

        // Fill result array with active owners
        uint256 resultIndex = 0;
        uint256 currentIndex = 0;

        for (
            uint256 i = 0;
            i < projectOwnersList.length && resultIndex < length;

        ) {
            address owner = projectOwnersList[i];
            Migration storage migration = migrations[owner];

            if (
                migration.active &&
                (migration.expiryTime == 0 ||
                    block.timestamp <= migration.expiryTime)
            ) {
                if (currentIndex >= _offset && resultIndex < length) {
                    result[resultIndex] = owner;
                    unchecked {
                        resultIndex++;
                    }
                }
                unchecked {
                    currentIndex++;
                }
            }

            // Gas optimization
            unchecked {
                i++;
            }
        }

        return result;
    }

    /**
     * @dev Gets detailed information about a migration
     * @param _projectOwner Project owner address
     * @return oldToken Old token address
     * @return newToken New token address
     * @return rate Conversion rate
     * @return totalMigrated Total tokens migrated
     * @return expiryTime Expiry timestamp
     * @return active Whether migration is active
     * @return name Migration name
     * @return description Migration description
     */
    function getMigrationDetails(
        address _projectOwner
    )
        external
        view
        migrationExists(_projectOwner)
        returns (
            address oldToken,
            address newToken,
            uint256 rate,
            uint256 totalMigrated,
            uint256 expiryTime,
            bool active,
            string memory name,
            string memory description
        )
    {
        Migration storage migration = migrations[_projectOwner];

        return (
            migration.oldToken,
            migration.newToken,
            migration.rate,
            migration.totalMigrated,
            migration.expiryTime,
            migration.active,
            migration.metadata.name,
            migration.metadata.description
        );
    }

    /**
     * @dev Gets extended migration metadata
     * @param _projectOwner Project owner address
     * @return name Migration name
     * @return description Migration description
     * @return logoURI Logo URI
     * @return createdAt Creation timestamp
     * @return websiteURL Website URL
     * @return socialURL Social media URL
     */
    function getMigrationMetadata(
        address _projectOwner
    )
        external
        view
        migrationExists(_projectOwner)
        returns (
            string memory name,
            string memory description,
            string memory logoURI,
            uint256 createdAt,
            string memory websiteURL,
            string memory socialURL
        )
    {
        MigrationMetadata storage metadata = migrations[_projectOwner].metadata;

        return (
            metadata.name,
            metadata.description,
            metadata.logoURI,
            metadata.createdAt,
            metadata.websiteURL,
            metadata.socialURL
        );
    }

    /**
     * @dev Calculates the expected output amount for a given input
     * @param _projectOwner Project owner address
     * @param _inputAmount Amount of old tokens
     * @return Expected new token amount after conversion
     */
    function calculateExpectedOutput(
        address _projectOwner,
        uint256 _inputAmount
    ) external view migrationExists(_projectOwner) returns (uint256) {
        Migration storage migration = migrations[_projectOwner];

        // Add checks for extreme decimal values
        if (
            migration.oldTokenDecimals > 30 || migration.newTokenDecimals > 30
        ) {
            revert TokenDecimalsTooHigh();
        }

        // Calculate converted amount with decimal adjustment
        uint256 convertedAmount;
        if (migration.oldTokenDecimals == migration.newTokenDecimals) {
            // Same decimals, use rate directly
            convertedAmount = (_inputAmount * migration.rate) / FEE_DENOMINATOR;
        } else if (migration.oldTokenDecimals < migration.newTokenDecimals) {
            // New token has more decimals, adjust upward
            uint256 decimalsDiff = migration.newTokenDecimals -
                migration.oldTokenDecimals;
            convertedAmount =
                (_inputAmount * migration.rate * (10 ** decimalsDiff)) /
                FEE_DENOMINATOR;
        } else {
            // Old token has more decimals, adjust downward
            uint256 decimalsDiff = migration.oldTokenDecimals -
                migration.newTokenDecimals;
            convertedAmount =
                (_inputAmount * migration.rate) /
                FEE_DENOMINATOR /
                (10 ** decimalsDiff);
        }

        // Return final amount (no fee deduction in this version)
        return convertedAmount;
    }

    /**
     * @dev Gets user deposit amount for a specific project migration
     * @param _user User address
     * @param _projectOwner Project owner address
     * @return Deposit amount
     */
    function getUserDeposit(
        address _user,
        address _projectOwner
    ) external view migrationExists(_projectOwner) returns (uint256) {
        Migration storage migration = migrations[_projectOwner];
        return userDeposits[_user][migration.oldToken];
    }

    /**
     * @dev Checks if a migration has expired
     * @param _projectOwner Project owner address
     * @return isExpired True if expired
     */
    function isMigrationExpired(
        address _projectOwner
    ) external view migrationExists(_projectOwner) returns (bool isExpired) {
        Migration storage migration = migrations[_projectOwner];
        if (migration.expiryTime == 0) {
            return false; // No expiry set
        }

        return block.timestamp > migration.expiryTime;
    }

    /**
     * @dev Gets platform statistics
     * @return totalMigrations Total migrations created
     * @return activeMigrations Number of active migrations
     * @return uniqueUsers Total unique users
     * @return totalVolume Total volume migrated
     * @return totalFees Total fees collected
     */
    function getPlatformStatistics()
        external
        view
        returns (
            uint256 totalMigrations,
            uint256 activeMigrations,
            uint256 uniqueUsers,
            uint256 totalVolume,
            uint256 totalFees
        )
    {
        uint256 active = 0;

        for (uint256 i = 0; i < projectOwnersList.length; ) {
            Migration storage migration = migrations[projectOwnersList[i]];
            if (
                migration.active &&
                (migration.expiryTime == 0 ||
                    block.timestamp <= migration.expiryTime)
            ) {
                active++;
            }

            // Gas optimization
            unchecked {
                i++;
            }
        }

        return (
            totalMigrationsCreated,
            active,
            totalUniqueUsers,
            totalTokensMigrated,
            totalFeesCollected
        );
    }

    /**
     * @dev Gets daily migration volumes for a range of days
     * @param _startDay Starting day (timestamp / 86400)
     * @param _days Number of days to retrieve
     * @return daysList Array of days (timestamps / 86400)
     * @return volumes Array of volumes for each day
     */
    function getDailyMigrationVolumes(
        uint256 _startDay,
        uint256 _days
    )
        external
        view
        returns (uint256[] memory daysList, uint256[] memory volumes)
    {
        daysList = new uint256[](_days);
        volumes = new uint256[](_days);

        for (uint256 i = 0; i < _days; ) {
            // Changed variable name from 'day' to 'currentDayIndex' to avoid shadowing
            uint256 currentDayIndex = _startDay + i;
            daysList[i] = currentDayIndex;
            volumes[i] = dailyMigrationVolume[currentDayIndex];

            // Gas optimization
            unchecked {
                i++;
            }
        }

        return (daysList, volumes);
    }

    /**
     * @dev Gets token depositors list for a specific token (paginated)
     * @param _token Token address
     * @param _offset Starting index
     * @param _limit Maximum number of items to return
     * @return depositors Array of depositor addresses
     * @return amounts Array of deposit amounts
     */
    function getTokenDepositors(
        address _token,
        uint256 _offset,
        uint256 _limit
    )
        external
        view
        returns (address[] memory depositors, uint256[] memory amounts)
    {
        address[] memory allDepositors = tokenDepositorsList[_token];

        if (_offset >= allDepositors.length) {
            return (new address[](0), new uint256[](0));
        }

        uint256 end = _offset + _limit;
        if (end > allDepositors.length) {
            end = allDepositors.length;
        }

        uint256 length = end - _offset;
        depositors = new address[](length);
        amounts = new uint256[](length);

        for (uint256 i = 0; i < length; ) {
            address depositor = allDepositors[_offset + i];
            depositors[i] = depositor;
            amounts[i] = userDeposits[depositor][_token];

            // Gas optimization
            unchecked {
                i++;
            }
        }

        return (depositors, amounts);
    }

    /**
     * @dev Gets detailed user activity statistics
     * @param _user User address
     * @return lastActiveTime Last active time
     * @return totalTransactions Total transactions
     * @return totalMigrations Total migrations
     * @return totalValueMigrated Total value migrated
     */
    function getUserActivityStats(
        address _user
    )
        external
        view
        returns (
            uint256 lastActiveTime,
            uint256 totalTransactions,
            uint256 totalMigrations,
            uint256 totalValueMigrated
        )
    {
        UserActivity storage activity = userActivities[_user];

        return (
            activity.lastActiveTime,
            activity.totalTransactions,
            activity.totalMigrations,
            activity.totalValueMigrated
        );
    }

    /**
     * @dev Gets archived migrations (paginated)
     * @param _offset Starting index
     * @param _limit Maximum number of items to return
     * @return projectOwners Array of project owner addresses
     * @return oldTokens Array of old token addresses
     * @return newTokens Array of new token addresses
     * @return totalsMigrated Array of total migrated amounts
     * @return timestamps Array of timestamps
     */
    function getArchivedMigrations(
        uint256 _offset,
        uint256 _limit
    )
        external
        view
        returns (
            address[] memory projectOwners,
            address[] memory oldTokens,
            address[] memory newTokens,
            uint256[] memory totalsMigrated,
            uint256[] memory timestamps
        )
    {
        if (_offset >= archivedMigrations.length) {
            return (
                new address[](0),
                new address[](0),
                new address[](0),
                new uint256[](0),
                new uint256[](0)
            );
        }

        uint256 end = _offset + _limit;
        if (end > archivedMigrations.length) {
            end = archivedMigrations.length;
        }

        uint256 length = end - _offset;
        projectOwners = new address[](length);
        oldTokens = new address[](length);
        newTokens = new address[](length);
        totalsMigrated = new uint256[](length);
        timestamps = new uint256[](length);

        for (uint256 i = 0; i < length; ) {
            MigrationArchive storage archive = archivedMigrations[_offset + i];
            projectOwners[i] = archive.projectOwner;
            oldTokens[i] = archive.oldToken;
            newTokens[i] = archive.newToken;
            totalsMigrated[i] = archive.totalMigrated;
            timestamps[i] = archive.timestamp;

            // Gas optimization
            unchecked {
                i++;
            }
        }

        return (
            projectOwners,
            oldTokens,
            newTokens,
            totalsMigrated,
            timestamps
        );
    }

    /**
     * @dev Allows the contract to receive native currency
     */
    receive() external payable {}
}

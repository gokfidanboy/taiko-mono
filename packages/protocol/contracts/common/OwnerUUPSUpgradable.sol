// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/
//
//   Email: security@taiko.xyz
//   Website: https://taiko.xyz
//   GitHub: https://github.com/taikoxyz
//   Discord: https://discord.gg/taikoxyz
//   Twitter: https://twitter.com/taikoxyz
//   Blog: https://mirror.xyz/labs.taiko.eth
//   Youtube: https://www.youtube.com/@taikoxyz

pragma solidity 0.8.24;

import "lib/openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/// @title OwnerUUPSUpgradable
/// @notice This contract serves as the base contract for many core components.
/// @dev We didn't use OpenZeppelin's PausableUpgradeable and
/// ReentrancyGuardUpgradeable contract to optimize storage reads.
abstract contract OwnerUUPSUpgradable is UUPSUpgradeable, OwnableUpgradeable {
    uint8 private constant _FALSE = 1;
    uint8 private constant _TRUE = 2;

    uint8 private _reentry; // slot 1
    uint8 private _paused;
    uint256[49] private __gap;

    event Paused(address account);
    event Unpaused(address account);

    error REENTRANT_CALL();
    error INVALID_PAUSE_STATUS();

    modifier nonReentrant() {
        if (_reentry == _TRUE) revert REENTRANT_CALL();
        _reentry = _TRUE;
        _;
        _reentry = _FALSE;
    }

    modifier whenPaused() {
        if (!paused()) revert INVALID_PAUSE_STATUS();
        _;
    }

    modifier whenNotPaused() {
        if (paused()) revert INVALID_PAUSE_STATUS();
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function pause() public virtual whenNotPaused {
        _paused = _TRUE;
        emit Paused(msg.sender);
        _authorizePause(msg.sender);
    }

    function unpause() public virtual whenPaused {
        _paused = _FALSE;
        emit Unpaused(msg.sender);
        _authorizePause(msg.sender);
    }

    function paused() public view returns (bool) {
        return _paused == _TRUE;
    }

    function _authorizeUpgrade(address) internal virtual override onlyOwner { }
    function _authorizePause(address) internal virtual onlyOwner { }

    /// @notice Initializes the contract with an address manager.
    // solhint-disable-next-line func-name-mixedcase
    function __OwnerUUPSUpgradable_init() internal virtual {
        __Ownable_init();
        _reentry = _FALSE;
        _paused = _FALSE;
    }

    function _inNonReentrant() internal view returns (bool) {
        return _reentry == _TRUE;
    }
}

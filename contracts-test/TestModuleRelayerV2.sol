pragma solidity ^0.5.4;
import "../contracts/wallet/BaseWallet.sol";
import "../contracts/modules/common/BaseModule.sol";
import "../contracts/modules/common/RelayerModuleV2.sol";

/**
 * @title TestModule
 * @dev Basic test module subclassing RelayerModuleV2 (otherwise identical to TestModule.sol).
 * @author Olivier VDB - <olivier@argent.xyz>
 */
contract TestModuleRelayerV2 is BaseModule, RelayerModuleV2 {

    bytes32 constant NAME = "TestModuleRelayerV2";

    bool boolVal;
    uint uintVal;

    constructor(ModuleRegistry _registry, bool _boolVal, uint _uintVal) BaseModule(_registry, GuardianStorage(0), NAME) public {
        boolVal = _boolVal;
        uintVal = _uintVal;
    }

    function invalidOwnerChange(BaseWallet _wallet) external {
        _wallet.setOwner(address(0)); // this should fail
    }

    function setIntOwnerOnly(BaseWallet _wallet, uint _val) external onlyWalletOwner(_wallet) {
        uintVal = _val;
    }
    function clearInt() external {
        uintVal = 0;
    }

    function init(BaseWallet _wallet) public onlyWallet(_wallet) {
        enableStaticCalls(_wallet, address(this));
    }

    function enableStaticCalls(BaseWallet _wallet, address _module) public {
        _wallet.enableStaticCall(_module, bytes4(keccak256("getBoolean()")));
        _wallet.enableStaticCall(_module, bytes4(keccak256("getUint()")));
        _wallet.enableStaticCall(_module, bytes4(keccak256("getAddress(address)")));
    }

    function getBoolean() public view returns (bool) {
        return boolVal;
    }

    function getUint() public view returns (uint) {
        return uintVal;
    }

    function getAddress(address _addr) public pure returns (address) {
        return _addr;
    }

    // *************** Implementation of RelayerModule methods ********************* //

    // Overrides to use the incremental nonce and save some gas
    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 /* _signHash */) internal returns (bool) {
        return checkAndUpdateNonce(_wallet, _nonce);
    }

    function validateSignatures(
        BaseWallet _wallet,
        bytes memory /* _data */,
        bytes32 _signHash,
        bytes memory _signatures
    )
        internal
        view
        returns (bool)
    {
        address signer = recoverSigner(_signHash, _signatures, 0);
        return isOwner(_wallet, signer); // "GM: signer must be owner"
    }

    function getRequiredSignatures(BaseWallet /* _wallet */, bytes memory /*_data */) internal view returns (uint256) {
        return 1;
    }

}
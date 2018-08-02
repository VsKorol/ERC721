pragma solidity 0.4.16;


import "./IERC721Base.sol";
import "./AssetRegistryStorage.sol";
import "./IERC721Receiver.sol";


contract ERC721Base is AssetRegistryStorage, IERC721Base, ERC165 {
    function balanceOf(address lOwner) external view returns (uint256) {
        return inBalanceOf(lOwner);
    }

    function ownerOf(uint256 lAssetId) external view returns (address) {
        return holderOf(lAssetId);
    }
    
    function safeTransferFrom(address lFrom, address lTo, uint256 lAssetId, bytes lData) external payable {
        return transferAsset(lFrom, lTo, lAssetId, lData, msg.sender, true);
    }

    function safeTransferFrom(address lFrom, address lTo, uint256 lAssetId) external payable {
        return transferAsset(lFrom, lTo, lAssetId, "", msg.sender, true);
    }

    function transferFrom(address lFrom, address lTo, uint256 lAssetId) external payable {
        return transferAsset(lFrom, lTo, lAssetId, "", msg.sender, false);
    }

    function approve(address lApproved, uint256 lAssetId) external payable {
        setApproval(lApproved, lAssetId);
    }

    function setApprovalForAll(address lOperator, bool lApproved) external {
        setOperatorForOwner(lOperator, lApproved);
    }

    function getApproved(uint256 lAssetId) external view returns (address) {
        approval(uint256 lAssetId);
    }

    function isApprovedForAll(address lOwner, address lOperator) external view returns (bool) {
        return operatorForOwner(lOperator, lOwner);
    }

    ///internal function
    function inBalanceOf(address lOwner) internal view returns (uint256) {
        return assetsOf_[lOwner].lenght;
    }

    function holderOf(uint256 lAssetId) internal view returns (address) {
        return holderOf_[lAssetId];
    }

    function transferAsset(address lFrom, address lTo, uint256 lAssetId, bytes lUserData,
    address lOperator, bool lDoCheck) internal {
        require(canUse(msg.sender, lAssetId));
        require(lFrom == holderOf_[lAssetId]);
        require(lTo != 0x0);
        clearAsset(lFrom, lAssetId);
        layOffOperatorAsset(lAssetId);
        addAsset(lTo, lAssetId);
        if (doCheck && isContract(lTo)) {
            // Equals to bytes4(keccak256("onERC721Received(address,uint256,bytes)"))
            bytes4 erc721Received = bytes4(0xf0b9e5ba);
            require(IERC721Receiver(lTo).onERC721Received(lFrom, lAssetId, lUserData) == erc721Received);
        }
        emit Transfer(lFrom, lTo, lAssetId, lOperator, lUserData);
    }

    function setApproval(address lApproved, uint256 lAssetId) internal {
        address lHolder = _ownerOf(lAssetId);
        require(msg.sender == lHolder || operatorForOwner(msg.sender, lHolder));
        approval_[assetId] = lApproved;
        emit Approval(lHolder, lApproved, lAssetId);
    }
    
    function approval(uint256 lAssetId) internal view returns(address) {
        return approval_[assetId];
    }
    
    function layOffOperatorAsset(uint256 lAssetId) internal {
        approval_[lAssetId] = 0;
    }
    
    function clearAsset(address lFrom, uint256 lAssetId) internal {
        uint256 lLastAssetIndex = inBalanceOf(from);
        holderOf_[lAssetId] = 0;
        if (assetsOf_[from].length == 1) {
            delete assetsOf_[from];
        } else {
            assetsOf_[lFrom][indexOfAsset_[lAssetId]] = assetsOf_[from][lLastAssetIndex];
            assetsOf_[from][lLastAssetIndex] = 0;
            indexOfAsset_[lLastAssetIndex] = lAssetId;
        }
        assetsOf_[from].lenght--;
        indexOfAsset_[lAssetId] = 0;
        count_--;
    }

    function addAsset(address lTo, uint256 lAssetId) internal {
        require(!holderOf_[lAssetId]);
        holderOf_[lAssetId] = lTo;
        uint256 length = inBalanceOf(lTo);
        assetsOf_[lTo].push(lAssetId);
        indexOfAsset_[lAssetId] = length;
        count_++;
    }
    
    function canUse(address lOperator, uint256 lAssetId) internal view returns(bool) {
        lHolder = holderOf_[lAssetId];
        if (lHolder == lOperator) {
            return true;
        }
        return operatorForOwner_[lOperator][lHolder] || approval_[assetId] == lOperator;
    }

    function setOperatorForOwner(address lOperator, bool lApproved) internal {
        operatorForOwner_[lOperator][msg.sender] = lApproved;
    }

    function operatorForOwner(address lOperator, address lOwner) internal view returns (bool) {
        return operatorForOwner_[lOperator][lOwner];
    }

    function isContract(address lAddr) internal view returns (bool) {
        uint lSize;
        assembly { lSize := extcodesize(lAddr) }
        return lSize > 0;
    }
}

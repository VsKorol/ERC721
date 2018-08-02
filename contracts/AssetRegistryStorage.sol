pragma solidity 0.4.20;


contract AssetRegistryStorage {

    string internal name_;
    string internal symbol_;
    string internal description_;
///Stores total number of assets, lead by this register
    uint256 internal count_;
///Stores data set of assets belonging this account
    mapping(address => uint256[]) internal assetsOf_;
///Stores current holder of assets
    mapping(uint256 => address) internal holderOf_;
///Stores index of assets in "assetsOf_" data set
    mapping(uint256 => uint256) internal indexOfAsset_;
///Stores permission for an operator to work with assets of the holder
    mapping(address => mapping(address => bool)) internal operatorForOwner_;
///Stores permission for operators to work with  the concrete asset
    mapping(address => mapping(uint256 => bool)) internal operatorForAsset_;
///Stores the operator for assets, which can work with the assets
    mapping(uint256 => address) internal approval_;
}

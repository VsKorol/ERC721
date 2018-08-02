pragma solidity ^0.4.20;


contract VRLandStorage {
    struct Rect {
        int256 x0;
        int256 y0;
        int256 x1;
        int256 y1;
    }

    Rect[] coordOfWorld;
    uint13 countWorlds;
    mapping(uint256=>uint10) rectLevelInWorld_;
    mapping(uint256=>uint256[]) objsInRect_;
    mapping(uint256=>uint10) existLevelInWorld_
    mapping(uint256=>uint256) heightOf_;
    mapping(uint256=>uint256) zeroHeight_
}

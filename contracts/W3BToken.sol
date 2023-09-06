// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC165.sol";
import "./ERC721.sol";
import "./ERC721Metadata.sol";
import "./ERC721TokenReceiver.sol";

contract W3BToken is ERC165, ERC721, ERC721Metadata, ERC721TokenReceiver {
    // ERC721
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    // ERC721Metadata
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    mapping(bytes4 => bool) private _supportedInterfaces;
    mapping(address => uint) private _balances;

    constructor() {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function _registerInterface(bytes4 interfaceID) internal {
        require(interfaceID != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceID] = true;
    }

    function supportsInterface(
        bytes4 interfaceID
    ) external view override returns (bool) {
        return _supportedInterfaces[interfaceID];
    }

    function balanceOf(
        address _owner
    ) external view override returns (uint256) {
        return _balances[_owner];
    }

    function ownerOf(
        uint256 _tokenId
    ) external view override returns (address) {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable override {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {}

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {}

    function approve(
        address _approved,
        uint256 _tokenId
    ) external payable override {}

    function setApprovalForAll(
        address _operator,
        bool _approved
    ) external override {}

    function getApproved(
        uint256 _tokenId
    ) external view override returns (address) {}

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view override returns (bool) {}

    function name() external pure override returns (string memory _name) {
        return "W3B Token";
    }

    function symbol() external pure override returns (string memory _symbol) {
        return "W3B";
    }

    function tokenURI(
        uint256 _tokenId
    ) external view override returns (string memory) {
        return "";
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}

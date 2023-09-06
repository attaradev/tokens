// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/ERC165.sol";
import "./interfaces/ERC721.sol";
import "./interfaces/ERC721Metadata.sol";
import "./interfaces/ERC721TokenReceiver.sol";
import "./interfaces/ERC721Enumerable.sol";

contract W3BToken is ERC165, ERC721, ERC721Metadata, ERC721Enumerable {
    struct Token {
        address owner;
        address approved;
        string uri;
    }

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 private constant _INTERFACE_ID_ERC721_RECEIVER = 0x150b7a02;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    uint256 private _totalSupply;
    mapping(uint256 => Token) private _tokens;
    mapping(bytes4 => bool) private _registeredInterfaces;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => bool)) private _operators;

    modifier notFalseInterfaceId(bytes4 interfaceId) {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _;
    }

    modifier authorized(uint256 tokenId) {
        require(
            _tokens[tokenId].owner == msg.sender ||
                _tokens[tokenId].approved == msg.sender ||
                _operators[_tokens[tokenId].owner][msg.sender],
            "ERC721: transfer caller is not owner nor approved"
        );
        _;
    }

    modifier validToken(uint256 tokenId) {
        require(_tokens[tokenId].owner != address(0), "ERC721: invalid token");
        _;
    }

    modifier notToZeroAddress(address to) {
        require(to != address(0), "ERC721: transfer to the zero address");
        _;
    }

    modifier fromOwner(uint256 tokenId, address from) {
        require(
            _tokens[tokenId].owner == msg.sender,
            "ERC721: transfer of token that is not owned"
        );
        _;
    }

    constructor() {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_RECEIVER);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function _registerInterface(
        bytes4 interfaceID
    ) internal notFalseInterfaceId(interfaceID) {
        _registeredInterfaces[interfaceID] = true;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        _tokens[_tokenId].owner = _to;
        _balances[_from] -= 1;
        _balances[_to] += 1;

        emit Transfer(_from, _to, _tokenId);
    }

    function supportsInterface(
        bytes4 interfaceID
    ) external view override notFalseInterfaceId(interfaceID) returns (bool) {
        return _registeredInterfaces[interfaceID];
    }

    function balanceOf(
        address _owner
    ) external view override returns (uint256) {
        require(
            _owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[_owner];
    }

    function ownerOf(
        uint256 _tokenId
    ) external view override validToken(_tokenId) returns (address) {
        return _tokens[_tokenId].owner;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    )
        public
        payable
        override
        validToken(_tokenId)
        authorized(_tokenId)
        notToZeroAddress(_to)
        fromOwner(_tokenId, _from)
    {
        if (_registeredInterfaces[_INTERFACE_ID_ERC721_RECEIVER]) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(
                msg.sender,
                _from,
                _tokenId,
                data
            );
            require(
                retval == _INTERFACE_ID_ERC721_RECEIVER,
                "ERC721: transfer to non ERC721Receiver implementer"
            );
        }

        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {
        safeTransferFrom(_from, _to, _tokenId, bytes(""));
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        payable
        override
        validToken(_tokenId)
        authorized(_tokenId)
        fromOwner(_tokenId, _from)
        notToZeroAddress(_to)
    {
        _transfer(_from, _to, _tokenId);
    }

    function approve(
        address _approved,
        uint256 _tokenId
    ) external payable override {
        require(
            _tokens[_tokenId].owner == msg.sender ||
                _operators[_tokens[_tokenId].owner][msg.sender],
            "ERC721: approve caller is not owner nor approved"
        );
        _tokens[_tokenId].approved = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(
        address _operator,
        bool _approved
    ) external override {
        _operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(
        uint256 _tokenId
    ) external view override validToken(_tokenId) returns (address) {
        return _tokens[_tokenId].approved;
    }

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view override returns (bool) {
        return _operators[_owner][_operator];
    }

    function name() external pure override returns (string memory _name) {
        return "W3B Token";
    }

    function symbol() external pure override returns (string memory _symbol) {
        return "W3B";
    }

    function tokenURI(
        uint256 _tokenId
    ) external view override returns (string memory) {
        return _tokens[_tokenId].uri;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function tokenByIndex(
        uint256 _index
    ) external view override validToken(_index) returns (uint256) {
        require(
            _index < _totalSupply,
            "ERC721Enumerable: global index out of bounds"
        );
        return _index;
    }

    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    ) external view override returns (uint256) {
        require(
            _index < _balances[_owner],
            "ERC721Enumerable: owner index out of bounds"
        );
        return _index;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignatureDemo {
  address owner;
  address couponSigner;

  mapping(address => bool) _mintedAddresses;

  using ECDSA for bytes32;

  error InvalidSignatureLength();

  constructor(address _couponSigner) {
    owner = msg.sender;
    couponSigner = _couponSigner;
  }

  // ##### USING PARSED RSV VALUES
  struct Coupon {
    bytes32 r;
    bytes32 s;
    uint8 v;
  }

  function _isVerifiedCoupon(bytes32 digest, Coupon memory coupon) internal view returns (bool) {
    address signer = ecrecover(digest, coupon.v, coupon.r, coupon.s);
    require(signer != address(0), "ECDSA: invalid signature");
    return signer == couponSigner;
  }

  function _createMessageDigest(address _address) internal pure returns (bytes32) {
    return
      keccak256(
        abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(_address)))
      );
  }

  function mintNew(Coupon memory coupon) external payable {
    require(_isVerifiedCoupon(_createMessageDigest(msg.sender), coupon), "Coupon is not valid.");

    require(!_mintedAddresses[msg.sender], "Wallet has already minted.");

    _mintedAddresses[msg.sender] = true;
  }

  function isMessageValid(bytes memory _signature) public view returns (address, bool) {
    bytes32 messagehash = keccak256(abi.encodePacked(address(this), msg.sender));
    address signer = messagehash.toEthSignedMessageHash().recover(_signature);

    if (owner == signer) {
      return (signer, true);
    } else {
      return (signer, false);
    }
  }

  function verify(
    address _signer,
    string memory _message,
    bytes memory _sig
  ) external pure returns (bool) {
    bytes32 messageHash = getMessageHash(_message);
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

    return recover(ethSignedMessageHash, _sig) == _signer;
  }

  function getMessageHash(string memory _message) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(_message));
  }

  function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
  }

  function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
    return ecrecover(_ethSignedMessageHash, v, r, s);
  }

  function _split(bytes memory _sig)
    internal
    pure
    returns (
      bytes32 r,
      bytes32 s,
      uint8 v
    )
  {
    if (_sig.length != 65) revert InvalidSignatureLength();

    assembly {
      r := mload(add(_sig, 32))
      s := mload(add(_sig, 64))
      v := byte(0, mload(add(_sig, 96)))
    }
  }
}

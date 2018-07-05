pragma solidity ^0.4.18;
contract Exchange {

  address public maker;
  address public taker;


  struct Bid {
    address maker;
    address taker;
    string status;
    string sort;
    uint startTime;
    uint endTime;
    uint amount;
    uint costPerKW;
  }


  Bid[] public bids;


  function Exchange() public {
  }

  function getBid(uint n) public returns(bytes32, bytes32,uint, uint, uint, uint){
    return(stringToBytes32(bids[n].status), stringToBytes32(bids[n].sort), bids[n].startTime, bids[n].endTime, bids[n].amount, bids[n].costPerKW);
  }

  function getBidMaker(uint n) public returns(address){
    return bids[n].maker;
  }

  function getBidTaker(uint n) public returns(address){
    return bids[n].taker;
  }

  function createBid(string sort,
                     uint startTime,
                     uint endTime,
                     uint amount,
                     uint costPerKW) public returns (bool){
    // To be able to test
    doCreateBid(msg.sender, sort, startTime, endTime, amount, costPerKW);
  }

  function doCreateBid(address _sender, string sort, uint startTime, uint endTime, uint amount, uint costPerKW)public returns (bool){
    Bid memory bid = Bid({maker: _sender,
                          taker: _sender,
                          status: 'created',
                          sort: sort,
                          startTime: startTime,
                          endTime: endTime,
                          amount: amount,
                          costPerKW: costPerKW});
    bids.push(bid);
    return true;
  }

  function PostBid(uint n) public returns (bool) {
    doPostBid(msg.sender, n);
  }

  function doPostBid(address _sender, uint n) public returns (bool){
    var (status, sort, startTime, endTime, amount, cost) = getBid(n);
    var m = bids[n].maker;
    var t = bids[n].taker;
    if(_sender == m && compareStrings(bytes32ToString(status), 'created')){
      bids[n].status = 'posted';
      return true;
    }
    return false;
  }

  function closeBid(uint n) public returns (bool){
    doCloseBid(msg.sender, n);
  }

  function doCloseBid(address _sender, uint n) public returns (bool){
    var (status, sort, startTime, endTime, amount, cost) = getBid(n);
    var m = bids[n].maker;
    var t = bids[n].taker;
    if(_sender == m && compareStrings(bytes32ToString(status), 'posted')){
      bids[n].status = 'closed';
      return true;
    }
    return false;
  }

  function compareStrings(string a, string b) public view returns (bool){
    return keccak256(a) == keccak256(b);
  }

  function stringToBytes32(string memory source) public returns (bytes32 result) {
      bytes memory tempEmptyStringTest = bytes(source);
      if (tempEmptyStringTest.length == 0) {
          return 0x0;
      }
      assembly {
          result := mload(add(source, 32))
      }
  }

  function bytes32ToString(bytes32 x) constant private returns (string) {
      bytes memory bytesString = new bytes(32);
      uint charCount = 0;
      for (uint j = 0; j < 32; j++) {
          byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
          if (char != 0) {
              bytesString[charCount] = char;
              charCount++;
          }
      }
      bytes memory bytesStringTrimmed = new bytes(charCount);
      for (j = 0; j < charCount; j++) {
          bytesStringTrimmed[j] = bytesString[j];
      }
      return string(bytesStringTrimmed);
  }

  function bidsCount() public returns (uint256) {
    return bids.length;
  }


  function queryDemandBids(uint startTime, uint endTime, uint cost) public returns (Bid[]){
    Bid[] demandBids;
    for (uint i=0; i < bidsCount(); i++) {
      if (compareStrings(bids[i].sort, 'DEMAND')){
        if(bids[i].startTime >= startTime && bids[i].endTime <= endTime && bids[i].costPerKW <= cost){
          demandBids.push(bids[i]);
        }
      }
    }
    return demandBids;
  }

  function demandBidsCount(uint startTime, uint endTime, uint cost) public returns (uint) {
    return queryDemandBids(startTime, endTime, cost).length;
  }

}

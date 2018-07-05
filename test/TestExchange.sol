pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Exchange.sol";

contract TestExchange{


  address maker;
  address taker;

  Exchange exchange;

  function beforeEach() {
    maker = 0x3b11c3517b601b4cf6caf2112ca0acff1d25f36a;
    taker = 0x3b11c3517b601b4cf6caf2112ca0acff1d25f36b;
    exchange = new Exchange();
  }

  function testCreateBid(){
    Assert.equal(exchange.doCreateBid(maker, "DEMAND",1,2, 2, 1), true, "Maker could create a bid");
    Assert.equal(exchange.bidsCount(), 1, "A new bid will be created");
    var (status, sort,startTime, endTime, amount, cost) = (exchange.getBid(0));
    Assert.equal(exchange.getBidMaker(0), maker, "the right maker should be set");
    Assert.equal(exchange.getBidTaker(0), maker, "the bid still has no taker");
    Assert.equal((status), bytes32('created'), "the right status should be set");
    Assert.equal((sort), bytes32('DEMAND'), "the right sort should be set");
    Assert.equal(amount, 2, "the right amount should be set");
    Assert.equal(cost, 1, "the right cost should be set");
  }

  function testPostBid(){
    exchange.doCreateBid(maker, "SUPPLY",1,2, 2, 2);
    Assert.equal(exchange.doPostBid(taker, 0), false, "Bid cannot be posted by some one else");
    Assert.equal(exchange.doPostBid(maker, 0), true, "Bid will be posted by the maker");
    var (status, sort,startTime, endTime, amount, cost) = (exchange.getBid(0));
    Assert.equal(bytes32(status), bytes32('posted'), "Bid will be posted by the maker");
  }

  function testCloseBid(){
    exchange.doCreateBid(maker, "SUPPLY",3,4, 2, 2);
    exchange.doPostBid(maker, 0);
    Assert.equal(exchange.doCloseBid(taker, 0), false, "Bid cannot be close by some one else");
    Assert.equal(exchange.doCloseBid(maker, 0), true, "Bid will be closed by the maker");
    var (status, sort,startTime, endTime, amount, cost) = (exchange.getBid(0));
    Assert.equal(bytes32(status), bytes32('closed'), "Bid status changes to closed status");
  }

  function testQueryDemandBids(){
    exchange.doCreateBid(maker, "SUPPLY",1,2, 1, 2);
    exchange.doCreateBid(maker, "DEMAND",2,4, 2, 2);
    exchange.doCreateBid(maker, "DEMAND",2,4, 2, 2);
    exchange.doCreateBid(maker, "DEMAND",3,6, 4, 2);
    exchange.doCreateBid(maker, "DEMAND",2,4, 4, 45);    
    Assert.equal(exchange.demandBidsCount(1,4,3), 2," Number of demand bids is 2");
  }
}

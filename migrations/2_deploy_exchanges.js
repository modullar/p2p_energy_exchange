var Exchange = artifacts.require("./Exchange.sol");
module.exports = function(deployer) {
  //e = Exchange.new(0x46f910bf710b8a52041c8a5e551c286a421f86ee, 0x4981fccf93950fa0ea5d384104a96c3d16462ec4, 0xa156d3ceec139abe68969a32fc9c08bbdc546445)
  deployer.deploy(Exchange);
};

// RUN: cd %S && truffle test

var config = require("../config.js")

var Contract = artifacts.require("./" + config.contractName + ".sol");
var Interface = artifacts.require("./_Interface" + config.contractName + ".sol");
Contract.abi = Interface.abi

var ExternalContract = artifacts.require("./Emitter.sol");

contract(config.contractName, function(accounts) {
  it("should correctly call external contract", async function() {
    const externalContract = await ExternalContract.deployed();

    await Contract.deployed().then(function (instance) {
      meta = instance;
      return meta.callExternal(externalContract.address);
    }).then(function (result) {
      assert.equal(result.logs.length, 1); 
        
      var log = result.logs[0];
      assert.equal(log.event, "EmitCheck");
      assert.equal(_.size(log.args), 1); 
      assert.equal(log.args.a.c[0], 0); 
    });
  });
});


from web3 import Web3, HTTPProvider
from solc import compile_source

class ContractInterface:

    def compile(self):
        return compile_source(self.source_code) # Compiled source code
    
    def __init__(self, code):
        self.source_code = code
        self.compile()
        
        # web3.py instance
        self.w3 = Web3(Web3.EthereumTesterProvider())

        # set pre-funded account as sender
        self.w3.eth.defaultAccount = self.w3.eth.accounts[0]

    def interface(self, name):
        return self.compile()['<stdin>:' + name]

    def instance(self, name, constructor_args=(), transaction_params={}, value=None):
        contract_interface = self.interface(name)
        

        # Instantiate and deploy contract
        ContractDeploy = self.w3.eth.contract(
            abi=contract_interface['abi'], 
            bytecode=contract_interface['bin']
        )

        # Submit the transaction that deploys the contract
        transactionParams = {}
        if value is not None:
            transaction_params["value"] = value
        tx_hash = ContractDeploy.constructor(*constructor_args).transact(transaction_params)

        # Wait for the transaction to be mined, and get the transaction receipt
        tx_receipt = self.w3.eth.waitForTransactionReceipt(tx_hash)

        # Create the contract instance with the newly-deployed address        
        contract_inst = self.w3.eth.contract(
            address=tx_receipt.contractAddress,
            abi=contract_interface['abi'],
        )

        return contract_inst
    
    def instance_at_address(self, name, address):
        contract_interface = self.interface(name)
    
        return self.w3.eth.contract(address=address, abi=contract_interface["abi"])


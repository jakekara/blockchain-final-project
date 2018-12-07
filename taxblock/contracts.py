def get_contract_interface(input_str,
                           contract_source_code,
                           constructor_args=()):
    """
    Code adapted from class lectures.
    
    Modified to accept arguments to pass to the constructor
    """
    
    # Solidity Compiler 

    compiled_sol = compile_source(contract_source_code) # Compiled source code
    contract_interface = compiled_sol['<stdin>:' + input_str]

    # web3.py instance
    w3 = Web3(Web3.EthereumTesterProvider())

    # set pre-funded account as sender
    w3.eth.defaultAccount = w3.eth.accounts[0]

    # Instantiate and deploy contract
    ContractDeploy = w3.eth.contract(abi=contract_interface['abi'], bytecode=contract_interface['bin'])

    # Submit the transaction that deploys the contract
    tx_hash = ContractDeploy.constructor(*constructor_args).transact()

    # Wait for the transaction to be mined, and get the transaction receipt
    tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

    # Create the contract instance with the newly-deployed address
    contract_inst = w3.eth.contract(
        address=tx_receipt.contractAddress,
        abi=contract_interface['abi'],
    )
    
    return w3, contract_inst

def get_contract_interface_from_address(address,
                                        input_str,
                                        contract_source_code):
    # Solidity Compiler

    compiled_sol = compile_source(contract_source_code) # Compiled source code
    contract_interface = compiled_sol['<stdin>:' + input_str]
    
    return w3.eth.contract(address=address, abi=contract_interface["abi"])



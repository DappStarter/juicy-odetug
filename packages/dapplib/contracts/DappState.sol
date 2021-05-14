pragma solidity  >=0.5.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IDappState.sol";
import "./DappLib.sol";


/********************************************************************************************/
/* This contract is auto-generated based on your choices in DappStarter. You can make       */
/* changes, but be aware that generating a new DappStarter project will require you to      */
/* merge changes. One approach you can take is to make changes in Dapp.sol and have it      */
/* call into this one. You can maintain all your data in this contract and your app logic   */
/* in Dapp.sol. This lets you update and deploy Dapp.sol with revised code and still        */
/* continue using this one.                                                                 */
/********************************************************************************************/

contract DappState is IDappState {
    // Allow DappLib(SafeMath) functions to be called for all uint256 types
    // (similar to "prototype" in Javascript)
    using DappLib for uint256; 

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FILE STORAGE: IPFS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    using DappLib for DappLib.Multihash;


/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ S T A T E @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/

    // Account used to deploy contract
    address private contractOwner;                  

/*>>>>>>>>>>>>>>>>>>>>>>>>>>> ACCESS CONTROL: ADMINISTRATOR ROLE  <<<<<<<<<<<<<<<<<<<<<<<<<<*/
    // Track authorized admins count to prevent lockout
    uint256 private authorizedAdminsCount = 1;                      

    // Admins authorized to manage contract
    mapping(address => uint256) private authorizedAdmins;                      

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ASSET VALUE TRACKING: TOKEN  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    string public name;
    string public symbol;
    uint256 public decimals;
    
    // Token balance for each address
    mapping(address => uint256) balances;              

    // Approval granted to transfer tokens by one address to another address                 
    mapping (address => mapping (address => uint256)) internal allowed; 

    // Tokens currently in circulation (you'll need to update this if you create more tokens)
    uint256 public total;                  

    // Tokens created when contract was deployed                             
    uint256 public initialSupply;         

    // Multiplier to convert to smallest unit                              
    uint256 public UNIT_MULTIPLIER;                                     

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FILE STORAGE: IPFS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    struct IpfsDocument {
        // Unique identifier -- defaults to multihash digest of file
        bytes32 docId;    

        bytes32 label;

        // Registration timestamp                                          
        uint256 timestamp;  

        // Owner of document                                        
        address owner;    

        // External Document reference                                          
        DappLib.Multihash docRef;                                   
    }

    // All added documents
    mapping(bytes32 => IpfsDocument) ipfsDocs;                            

    uint constant IPFS_DOCS_PAGE_SIZE = 50;
    uint256 public ipfsLastPage = 0;

    // All documents organized by page
    mapping(uint256 => bytes32[]) public ipfsDocsByPage;         

    // All documents for which an account is the owner
    mapping(address => bytes32[]) public ipfsDocsByOwner;              
    struct EntityData {
        bool exists;
        bytes32 id;
        address creator;
        bytes32 title;
        uint256 count;
    }

    mapping(bytes32 => EntityData) entities;                // Store some data
    bytes32[] public entityList;                            // Entity lookup

    mapping(address => bytes32[]) public entitiesByCreator; // Entities for which an account is the creator

    mapping(uint256 => bytes32[]) public entitiesByPage;    // Entities organized by page
    uint constant ENTITIES_DOCS_PAGE_SIZE = 50;
    uint256 public entitiesLastPage = 0;



/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ C O N S T R U C T O R @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/

    constructor() public 
    {
        contractOwner = msg.sender;       

/*>>>>>>>>>>>>>>>>>>>>>>>>>>> ACCESS CONTROL: ADMINISTRATOR ROLE  <<<<<<<<<<<<<<<<<<<<<<<<<<*/
        // Add account that deployed contract as an authorized admin
        authorizedAdmins[msg.sender] = 1;       

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ASSET VALUE TRACKING: TOKEN  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
        name = "Melodi";             
        symbol = "MLD";           
        decimals = 8;     

        // Multiplier to convert to smallest unit
        UNIT_MULTIPLIER = 10 ** uint256(decimals); 

        uint256 supply = 72000000;       

        // Convert supply to smallest unit
        total = supply.mul(UNIT_MULTIPLIER);    
        initialSupply = total;

        // Assign entire initial supply to contract owner
        balances[contractOwner] = total;    

    }

/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ E V E N T S @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ASSET VALUE TRACKING: TOKEN  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    // Fired when an account authorizes another account to spend tokens on its behalf
    event Approval          
                            (
                                address indexed owner, 
                                address indexed spender, 
                                uint256 value
                            );

    // Fired when tokens are transferred from one account to another
    event Transfer          
                            (
                                address indexed from, 
                                address indexed to, 
                                uint256 value
                            );

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FILE STORAGE: IPFS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    // Event fired when doc is added
    event AddIpfsDocument      
                    (
                        bytes32 indexed docId,
                        address indexed owner,
                        uint256 timestamp
                    );

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> COLLECTION: ENTITY  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    // Event fired when Entity is added
    event EntityAdd
                    (
                        bytes32 indexed id, 
                        address indexed entity, 
                        bytes32 indexed title, 
                        uint256 count
                    );

    // Event fired when Entity is updated
    event EntityUpdate
                    (
                        bytes32 indexed id, 
                        address indexed entity, 
                        bytes32 indexed title, 
                        uint256 count
                    );


/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ M O D I F I E R S @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/


/*>>>>>>>>>>>>>>>>>>>>>>>>>>> ACCESS CONTROL: ADMINISTRATOR ROLE  <<<<<<<<<<<<<<<<<<<<<<<<<<*/
    /**
    * @dev Modifier that requires the function caller to be a contract admin
    */
    modifier requireContractAdmin()
    {
        require(isContractAdmin(msg.sender), "Caller is not a contract administrator");
        // Modifiers require an "_" which indicates where the function body will be added
        _;
    }


/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ F U N C T I O N S @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/


/*>>>>>>>>>>>>>>>>>>>>>>>>>>> ACCESS CONTROL: ADMINISTRATOR ROLE  <<<<<<<<<<<<<<<<<<<<<<<<<<*/
    /**
    * @dev Checks if an account is an admin
    *
    * @param account Address of the account to check
    */
    function isContractAdmin
                            (
                                address account
                            ) 
                            public 
                            view
                            returns(bool) 
    {
        return authorizedAdmins[account] == 1;
    }


    /**
    * @dev Adds a contract admin
    *
    * @param account Address of the admin to add
    */
    function addContractAdmin
                            (
                                address account
                            ) 
                            external 
                            requireContractAdmin
    {
        require(account != address(0), "Invalid address");
        require(authorizedAdmins[account] < 1, "Account is already an administrator");

        authorizedAdmins[account] = 1;
        authorizedAdminsCount++;
    }

    /**
    * @dev Removes a previously added admin
    *
    * @param account Address of the admin to remove
    */
    function removeContractAdmin
                            (
                                address account
                            ) 
                            external 
                            requireContractAdmin
    {
        require(account != address(0), "Invalid address");
        require(authorizedAdminsCount >= 2, "Cannot remove last admin");

        delete authorizedAdmins[account];
        authorizedAdminsCount--;
    }

    /**
    * @dev Removes the last admin fully decentralizing the contract
    *
    * @param account Address of the admin to remove
    */
    function removeLastContractAdmin
                            (
                                address account
                            ) 
                            external 
                            requireContractAdmin
    {
        require(account != address(0), "Invalid address");
        require(authorizedAdminsCount == 1, "Not the last admin");

        delete authorizedAdmins[account];
        authorizedAdminsCount--;
    }


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ASSET VALUE TRACKING: TOKEN  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    /**
    * @dev Total supply of tokens
    */
    function totalSupply() 
                            external 
                            view 
                            returns (uint256) 
    {
        return total;
    }

    /**
    * @dev Gets the balance of the calling address.
    *
    * @return An uint256 representing the amount owned by the calling address
    */
    function balance()
                            public 
                            view 
                            returns (uint256) 
    {
        return balanceOf(msg.sender);
    }

    /**
    * @dev Gets the balance of the specified address.
    *
    * @param owner The address to query the balance of
    * @return An uint256 representing the amount owned by the passed address
    */
    function balanceOf
                            (
                                address owner
                            ) 
                            public 
                            view 
                            returns (uint256) 
    {
        return balances[owner];
    }

    /**
    * @dev Transfers token for a specified address
    *
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    * @return A bool indicating if the transfer was successful.
    */
    function transfer
                            (
                                address to, 
                                uint256 value
                            ) 
                            public 
                            returns (bool) 
    {
        require(to != address(0));
        require(to != msg.sender);
        require(value <= balanceOf(msg.sender));                                         

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
    * @dev Transfers tokens from one address to another
    *
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    * @return A bool indicating if the transfer was successful.
    */
    function transferFrom
                            (
                                address from, 
                                address to, 
                                uint256 value
                            ) 
                            public 
                            returns (bool) 
    {
        require(from != address(0));
        require(value <= allowed[from][msg.sender]);
        require(value <= balanceOf(from));                                         
        require(to != address(0));
        require(from != to);

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

    /**
    * @dev Checks the amount of tokens that an owner allowed to a spender.
    *
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance
                            (
                                address owner, 
                                address spender
                            ) 
                            public 
                            view 
                            returns (uint256) 
    {
        return allowed[owner][spender];
    }

    /**
    * @dev Approves the passed address to spend the specified amount of tokens 
    *      on behalf of msg.sender.
    *
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    * @return A bool indicating success (always returns true)
    */
    function approve
                            (
                                address spender, 
                                uint256 value
                            ) 
                            public 
                            returns (bool) 
    {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FILE STORAGE: IPFS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
    /**
    * @dev Adds a new IPFS doc
    *
    * @param docId Unique identifier (multihash digest of doc)
    * @param label Short, descriptive label for document
    * @param digest Digest of folder with doc binary and metadata
    * @param hashFunction Function used for generating doc folder hash
    * @param digestLength Length of doc folder hash
    */
    function addIpfsDocument
                        (
                            bytes32 docId,
                            bytes32 label,
                            bytes32 digest,
                            uint8 hashFunction,
                            uint8 digestLength
                        ) 
                        external 
                           requireContractAdmin
    {
        // Prevent empty string for docId
        require(docId[0] != 0, "Invalid docId");  

        // Prevent empty string for digest                             
        require(digest[0] != 0, "Invalid ipfsDoc folder digest");            

        // Prevent duplicate docIds   
        require(ipfsDocs[docId].timestamp == 0, "Document already exists");     

        ipfsDocs[docId] = IpfsDocument({
                                    docId: docId,
                                    label: label,
                                    timestamp: now,
                                    owner: msg.sender,
                                    docRef: DappLib.Multihash({
                                                    digest: digest,
                                                    hashFunction: hashFunction,
                                                    digestLength: digestLength
                                                })
                               });

        ipfsDocsByOwner[msg.sender].push(docId);
        if (ipfsDocsByPage[ipfsLastPage].length == IPFS_DOCS_PAGE_SIZE) {
            ipfsLastPage++;
        }
        ipfsDocsByPage[ipfsLastPage].push(docId);

        emit AddIpfsDocument(docId, msg.sender, ipfsDocs[docId].timestamp);
    }

    /**
    * @dev Gets individual IPFS doc by docId
    *
    * @param id DocumentId of doc
    */
    function getIpfsDocument
                    (
                        bytes32 id
                    )
                    external
                    view
                    returns(
                                bytes32 docId, 
                                bytes32 label,
                                uint256 timestamp, 
                                address owner, 
                                bytes32 docDigest,
                                uint8 docHashFunction,
                                uint8 docDigestLength
                    )
    {
        IpfsDocument memory ipfsDoc = ipfsDocs[id];
        docId = ipfsDoc.docId;
        label = ipfsDoc.label;
        timestamp = ipfsDoc.timestamp;
        owner = ipfsDoc.owner;
        docDigest = ipfsDoc.docRef.digest;
        docHashFunction = ipfsDoc.docRef.hashFunction;
        docDigestLength = ipfsDoc.docRef.digestLength;

    }

    /**
    * @dev Gets docs where account is/was an owner
    *
    * @param account Address of owner
    */
    function getIpfsDocumentsByOwner
                            (
                                address account
                            )
                            external
                            view
                            returns(bytes32[] memory)
    {
        require(account != address(0), "Invalid account");

        return ipfsDocsByOwner[account];
    }

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> COLLECTION: ENTITY  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

    /**
    * @dev Gets Entities by page
    *
    * @param page Page number you want to retrieve
    * @param resultsPerPage Amount of Entities displayed per page
    */
    function getEntitiesByPage
                                (
                                    uint256 page, 
                                    uint256 resultsPerPage
                                ) 
                                external 
                                view 
                                returns(bytes32[] memory) 
    {

        return DappLib.getItemsByPage(page, resultsPerPage, entityList);
    }

    /**
    * @dev Gets the amount of Entities in the collection
    */
    function getEntityCount
                        (
                        ) 
                        external 
                        view 
                        returns(
                            uint256 entityCount
                        )


    {
         entityCount = entityList.length;
    }    

    /**
    * @dev Gets a single Entity by id
    *
    * @param id Id of an Entity
    */
    function getEntity
                        (
                            bytes32 id
                        ) 
                        external 
                        view 
                        returns(
                            address creator, 
                            bytes32 title, 
                            uint256 count
                        )


    {
         creator = entities[id].creator;
         title = entities[id].title;
         count = entities[id].count;
    }    

    /**
    * @dev Gets all Entities of a specific creator
    *
    * @param account Address of creator's account 
    */
    function getEntitiesByCreator
                        (
                            address account
                        )
                        external
                        view
                        returns(bytes32[] memory)
    {
        require(account != address(0), "Invalid account");

        return entitiesByCreator[account];
    }

    function getMyEntities
                        (
                        )
                        external
                        view
                        returns(bytes32[] memory)
    {

        return entitiesByCreator[msg.sender];
    }

    /**
    * @dev Sets an Entity
    *
    * @param id Unique identifier 
    * @param title Title of Entity
    * @param count Numeric value of Entity
    */
    function setEntity
                        (
                            bytes32 id,
                            bytes32 title,
                            uint256 count   
                        ) 
                        external 
                        requireContractAdmin
    {
        // Prevent empty Id field
        require(id[0] != 0, "entity Id cannot be empty");

        // Add Entity if it does not exist, otherwise update the existing Entity
        if (!entities[id].exists) {
            require(title[0] != 0, "title cannot be empty");

            entityList.push(id);
            entitiesByCreator[msg.sender].push(id);

            if (entitiesByPage[entitiesLastPage].length == ENTITIES_DOCS_PAGE_SIZE) {
                entitiesLastPage++;
            }
            entitiesByPage[entitiesLastPage].push(id);
            emit EntityAdd(id, msg.sender, title, count);
        }else {
            emit EntityUpdate(id, msg.sender, title, count);
        }

        entities[id] = EntityData({
                                exists: true,
                                id: id,
                                creator: msg.sender,
                                title: title,
                                count: count
                            });
    }


//  Example functions that demonstrate how to call into this contract that holds state from
//  another contract. Look in ~/interfaces/IDappState.sol for the interface definitions and
//  in Dapp.sol for the actual calls into this contract.

    /**
    * @dev This is an EXAMPLE function that illustrates how functions in this contract can be
    *      called securely from another contract to READ state data. Using the Contract Access 
    *      block will enable you to make your contract more secure by restricting which external
    *      contracts can call functions in this contract.
    */
    function getContractOwner()
                                external
                                view
                                returns(address)
    {
        return contractOwner;
    }

    uint256 counter;    // This is an example variable used only to demonstrate calling
                        // a function that writes state from an external contract. It and
                        // "incrementCounter" and "getCounter" functions can (should?) be deleted.
    /**
    * @dev This is an EXAMPLE function that illustrates how functions in this contract can be
    *      called securely from another contract to WRITE state data. Using the Contract Access 
    *      block will enable you to make your contract more secure by restricting which external
    *       contracts can call functions in this contract.
    */
    function incrementCounter
                            (
                                uint256 increment
                            )
                            external
                            // Enable the modifier below if using the Contract Access feature
                            // requireContractAuthorized
    {
        // NOTE: If another contract is calling this function, then msg.sender will be the address
        //       of the calling contract and NOT the address of the user who initiated the
        //       transaction. It is possible to get the address of the user, but this is 
        //       spoofable and therefore not recommended.
        
        require(increment > 0 && increment < 10, "Invalid increment value");
        counter = counter.add(increment);   // Demonstration of using SafeMath to add to a number
                                            // While verbose, using SafeMath everywhere that you
                                            // add/sub/div/mul will ensure your contract does not
                                            // have weird overflow bugs.
    }

    /**
    * @dev This is an another EXAMPLE function that illustrates how functions in this contract can be
    *      called securely from another contract to READ state data. Using the Contract Access 
    *      block will enable you to make your contract more secure by restricting which external
    *      contracts can call functions in this contract.
    */
    function getCounter()
                                external
                                view
                                returns(uint256)
    {
        return counter;
    }

}   



pragma solidity ^0.5.0;

contract PartnershipAgreement {
    address public CompanyA;
    address public CompanyB;

    struct agreementSign {
        bool signedByA;
        bool signedByB;
    }

    //mappings for signing the agreemtn and getting the stored certificate
    mapping(bytes32 => agreementSign) agreementSignatures;
    mapping(address => Certificate) public getcertificate;

    struct Certificate {
        address CompanyA;
        address CompanyB;
        uint256 expiryDate;
    }

    //contract can be deployed by either CompanyA or CompanyB or a third party
    constructor(address A, address B) public {
        CompanyA = A;
        CompanyB = B;
    }

    //event for emitting once both parties sign the agreement , values from events can be used in front end
    event PartnershipSigned(address CompanyA, address CompanyB, uint256 now);

    //event for isssuing certificate , values from events can be used in front end
    event certificateIssued(
        address CompanyA,
        address CompanyB,
        address certificateAddress,
        uint256 _time
    );

    event noAgreement(address CompanyA, address CompanyB, string message);
    // In remix , the signAgreement function needs to be called with a hash value (suppposed to be recieved from front end using crytography function and metamask)
    // sample 32 bytes hash value - 0x7465737400000000000000000000000000000000000000000000000000000000

    function signAgreement(bytes32 hash) public returns (bool success) {
        if (msg.sender != CompanyA && msg.sender != CompanyB) revert("This address does not belong to Company A or B");
        if (msg.sender == CompanyA) agreementSignatures[hash].signedByA = true;
        if (msg.sender == CompanyB) agreementSignatures[hash].signedByB = true;

        if (
            agreementSignatures[hash].signedByA == true &&
            agreementSignatures[hash].signedByB == true
        ) {
            //  emit agreemnt signed event
            emit PartnershipSigned(CompanyA, CompanyB, now);

            // call function to issue certicate
            issueCertificate(CompanyA, CompanyB, getValidity());
            //if either parties didnot sign the agreemnt
        } else {
            // agreement has not been signed yet
            emit noAgreement(
                CompanyA,
                CompanyB,
                "Certificate was not issued since either company has not signed the agreement yet"
            );
        }
        return true;
    }

    function issueCertificate(
        address _partner1,
        address _partner2,
        uint256 _agreementexpirydate
    ) private returns (address certificateAddress) {
        // creates certificate address
        certificateAddress = address(
            bytes20(sha256(abi.encodePacked(msg.sender, now)))
        );
        // create certificate data
        getcertificate[certificateAddress] = Certificate(
            CompanyA,
            CompanyB,
            getValidity()
        );

        // creates the event, to be used to query all the certificates
        emit certificateIssued(
            _partner1,
            _partner2,
            certificateAddress,
            _agreementexpirydate
        );
    }

    // partnership is signed for a year from the date of agreement
    function getValidity() private view returns (uint256 time) {
        return block.timestamp + 365 days;
    }
}

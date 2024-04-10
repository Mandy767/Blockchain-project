// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.2;
// pragma experimental ABIEncoderV2;

contract Land {
    struct Landreg {
        uint id;
        uint area;
        string city;
        string state;
        uint landPrice;
        uint propertyPID;
        uint physicalSurveyNumber;
        string ipfsHash;
        string document;
    }

    struct User {
        address id;
        string name;
        uint age;
        string city;
        string aadharNumber;
        string panNumber;
        string document;
        string email;
    }

    struct LandInspector {
        uint id;
        string name;
        uint age;
        string designation;
    }

    struct LandRequest {
        uint reqId;
        address sellerId;
        address buyerId;
        uint landId;
    }

    mapping(uint => Landreg) public lands;
    mapping(uint => LandInspector) public InspectorMapping;
    mapping(address => User) public UserMapping;
    mapping(uint => LandRequest) public RequestsMapping;

    mapping(address => bool) public RegisteredAddressMapping;
    mapping(address => bool) public RegisteredUserMapping;
    mapping(address => bool) public UserVerification;
    mapping(address => bool) public UserRejection;
    mapping(uint => bool) public LandVerification;
    mapping(uint => address) public LandOwner;
    mapping(uint => bool) public RequestStatus;
    mapping(uint => bool) public RequestedLands;
    mapping(uint => bool) public PaymentReceived;

    address public Land_Inspector;
    address[] public users;
    uint public landsCount;
    uint public inspectorsCount;
    uint public usersCount;
    uint public requestsCount;

    event Registration(address _registrationId);
    event LandRequested(address _sellerId);
    event RequestApproved(uint _reqId);
    event Verified(address _id);
    event Rejected(address _id);

    modifier onlyLandInspector() {
        require(
            msg.sender == Land_Inspector,
            "Only land inspector can call this function"
        );
        _;
    }
    modifier onlyUser() {
        require(isUser(msg.sender), "Caller is not a registered User");
        _;
    }

    constructor() {
        Land_Inspector = msg.sender;
        addLandInspector("Inspector 1", 45, "Tehsil Manager");
    }

    function addLandInspector(
        string memory _name,
        uint _age,
        string memory _designation
    ) private {
        inspectorsCount++;
        InspectorMapping[inspectorsCount] = LandInspector(
            inspectorsCount,
            _name,
            _age,
            _designation
        );
    }

    function addLand(
        uint _area,
        string memory _city,
        string memory _state,
        uint _landPrice,
        uint _propertyPID,
        uint _surveyNum,
        string memory _ipfsHash,
        string memory _document
    ) public onlyUser {
        require(isVerified(msg.sender), "User is not verified");

        landsCount++;
        lands[landsCount] = Landreg(
            landsCount,
            _area,
            _city,
            _state,
            _landPrice,
            _propertyPID,
            _surveyNum,
            _ipfsHash,
            _document
        );
        LandOwner[landsCount] = msg.sender;
    }

    function registerUser(
        string memory _name,
        uint _age,
        string memory _city,
        string memory _aadharNumber,
        string memory _panNumber,
        string memory _document,
        string memory _email
    ) public {
        require(
            !RegisteredAddressMapping[msg.sender],
            "User is already registered"
        );

        RegisteredAddressMapping[msg.sender] = true;
        RegisteredUserMapping[msg.sender] = true;
        usersCount++;
        UserMapping[msg.sender] = User(
            msg.sender,
            _name,
            _age,
            _city,
            _aadharNumber,
            _panNumber,
            _document,
            _email
        );
        users.push(msg.sender);

        emit Registration(msg.sender);
    }

    function requestLand(address _sellerId, uint _landId) public onlyUser {
        require(isVerified(msg.sender), "User is not verified");

        requestsCount++;
        RequestsMapping[requestsCount] = LandRequest(
            requestsCount,
            _sellerId,
            msg.sender,
            _landId
        );
        RequestStatus[requestsCount] = false;
        RequestedLands[requestsCount] = true;

        emit LandRequested(_sellerId);
    }

    function approveRequest(uint _reqId) public onlyUser {
        RequestStatus[_reqId] = true;

        emit RequestApproved(_reqId);
    }

    function verifyUser(address _userId) public onlyLandInspector {
        UserVerification[_userId] = true;
        emit Verified(_userId);
    }

    function rejectUser(address _userId) public onlyLandInspector {
        UserRejection[_userId] = true;
        emit Rejected(_userId);
    }

    function verifyLand(uint _landId) public onlyLandInspector {
        LandVerification[_landId] = true;
    }

    function isLandVerified(uint _id) public view returns (bool) {
        return LandVerification[_id];
    }

    function isVerified(address _id) public view returns (bool) {
        return UserVerification[_id];
    }

    function isRejected(address _id) public view returns (bool) {
        return UserRejection[_id];
    }

    function isUser(address _id) public view returns (bool) {
        return RegisteredUserMapping[_id];
    }

    function isLandInspector(address _id) public view returns (bool) {
        return Land_Inspector == _id;
    }

    function isRegistered(address _id) public view returns (bool) {
        return RegisteredAddressMapping[_id];
    }

    function getLandsCount() public view returns (uint) {
        return landsCount;
    }

    function getUsersCount() public view returns (uint) {
        return usersCount;
    }

    function getUser() public view returns (address[] memory) {
        return (users);
    }

    function getBuyerDetails(
        address i
    )
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            uint,
            string memory
        )
    {
        return (
            UserMapping[i].name,
            UserMapping[i].city,
            UserMapping[i].panNumber,
            UserMapping[i].document,
            UserMapping[i].email,
            UserMapping[i].age,
            UserMapping[i].aadharNumber
        );
    }

    function getRequestDetails(
        uint i
    ) public view returns (address, address, uint, bool) {
        return (
            RequestsMapping[i].sellerId,
            RequestsMapping[i].buyerId,
            RequestsMapping[i].landId,
            RequestStatus[i]
        );
    }

    function isRequested(uint _id) public view returns (bool) {
        return RequestedLands[_id];
    }

    function isApproved(uint _id) public view returns (bool) {
        return RequestStatus[_id];
    }

    function LandOwnershipTransfer(uint _landId, address _newOwner) public {
        require(isLandInspector(msg.sender));

        LandOwner[_landId] = _newOwner;
    }

    function isPaid(uint _landId) public view returns (bool) {
        return PaymentReceived[_landId];
    }

    function payment(
        address payable _receiver,
        uint _landId,
        uint _landPrice
    ) public payable {
        require(msg.value >= _landPrice, "Insufficient payment amount");

        PaymentReceived[_landId] = true;
        _receiver.transfer(_landPrice);
    }
}
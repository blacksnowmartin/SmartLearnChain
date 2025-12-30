# CoworkingSpaceContract

pragma solidity ^0.8.0;

contract CoworkingSpace {
    struct Space {
        uint id;
        string name;
        string location;
        uint pricePerHour;
        bool isAvailable;
    }

    struct Booking {
        uint spaceId;
        address user;
        uint startTime;
        uint endTime;
    }

    mapping(uint => Space) public spaces;
    mapping(uint => Booking) public bookings;
    uint public spaceCount;
    uint public bookingCount;

    event SpaceAdded(uint id, string name, string location, uint pricePerHour);
    event SpaceBooked(uint bookingId, uint spaceId, address user, uint startTime, uint endTime);
    event SpaceAvailabilityUpdated(uint spaceId, bool isAvailable);

    function addSpace(string memory _name, string memory _location, uint _pricePerHour) public {
        spaceCount++;
        spaces[spaceCount] = Space(spaceCount, _name, _location, _pricePerHour, true);
        emit SpaceAdded(spaceCount, _name, _location, _pricePerHour);
    }

    function bookSpace(uint _spaceId, uint _startTime, uint _endTime) public {
        require(spaces[_spaceId].isAvailable, "Space is not available");
        require(_startTime < _endTime, "Invalid booking time");

        bookingCount++;
        bookings[bookingCount] = Booking(_spaceId, msg.sender, _startTime, _endTime);
        spaces[_spaceId].isAvailable = false;
        emit SpaceBooked(bookingCount, _spaceId, msg.sender, _startTime, _endTime);
    }

# Think of a way of adding a functionality
    function updateSpaceAvailability(uint _spaceId, bool _isAvailable) public {
        spaces[_spaceId].isAvailable = _isAvailable;
        emit SpaceAvailabilityUpdated(_spaceId, _isAvailable);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketingContract {
    struct Ticket {
        uint256 eventId;
        address owner;
        bool isAvailable;
    }

    struct Event {
        uint256 eventId;
        string name;
        string date;
        string venue;
        uint256 totalTickets;
        uint256 pricePerTicket;
        uint256 ticketsSold;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => Ticket[]) public eventTickets;

    event TicketPurchased(
        uint256 indexed eventId,
        address indexed buyer,
        uint256 ticketId
    );
    event TicketTransferred(
        uint256 indexed eventId,
        address indexed from,
        address indexed to,
        uint256 ticketId
    );
    event TicketResold(
        uint256 indexed eventId,
        address indexed seller,
        address indexed buyer,
        uint256 ticketId
    );

    function createEvent(
        uint256 eventId,
        string memory name,
        string memory date,
        string memory venue,
        uint256 totalTickets,
        uint256 pricePerTicket
    ) external {
        require(
            events[eventId].eventId == 0,
            "Event with the same ID already exists"
        );

        Event storage newEvent = events[eventId];
        newEvent.eventId = eventId;
        newEvent.name = name;
        newEvent.date = date;
        newEvent.venue = venue;
        newEvent.totalTickets = totalTickets;
        newEvent.pricePerTicket = pricePerTicket;
        newEvent.ticketsSold = 0;
    }

    function purchaseTicket(uint256 eventId) external payable {
        Event storage selectedEvent = events[eventId];
        require(selectedEvent.eventId != 0, "Event does not exist");
        require(
            selectedEvent.ticketsSold < selectedEvent.totalTickets,
            "All tickets are sold out"
        );
        require(
            msg.value >= selectedEvent.pricePerTicket,
            "Insufficient payment"
        );

        Ticket[] storage tickets = eventTickets[eventId];
        uint256 ticketId = tickets.length;

        tickets.push(Ticket(eventId, msg.sender, true));

        selectedEvent.ticketsSold++;

        emit TicketPurchased(eventId, msg.sender, ticketId);
    }

    function transferTicket(
        uint256 eventId,
        address to,
        uint256 ticketId
    ) external {
        Ticket[] storage tickets = eventTickets[eventId];
        require(ticketId < tickets.length, "Invalid ticket ID");

        Ticket storage ticket = tickets[ticketId];
        require(msg.sender == ticket.owner, "You are not the ticket owner");

        ticket.owner = to;

        emit TicketTransferred(eventId, msg.sender, to, ticketId);
    }



    function resellTicket(
        uint256 eventId,
        address buyer,
        uint256 ticketId
    ) external payable {
        Event storage selectedEvent = events[eventId];
        require(selectedEvent.eventId != 0, "Event does not exist");
        require(
            msg.value >= selectedEvent.pricePerTicket,
            "Insufficient payment"
        );

        Ticket[] storage tickets = eventTickets[eventId];
        require(ticketId < tickets.length, "Invalid ticket ID");

        Ticket storage ticket = tickets[ticketId];
        require(msg.sender == ticket.owner, "You are not the ticket owner");
        require(ticket.isAvailable, "Ticket is not available for resale");

        ticket.owner = buyer;
        ticket.isAvailable = false;

        emit TicketResold(eventId, msg.sender, buyer, ticketId);
    }



    function getEventDetails(uint256 eventId)
        external
        view
        returns (
            string memory name,
            string memory date,
            string memory venue,
            uint256 totalTickets,
            uint256 pricePerTicket,
            uint256 ticketsSold
        )
    {
        Event storage selectedEvent = events[eventId];
        require(selectedEvent.eventId != 0, "Event does not exist");

        return (
            selectedEvent.name,
            selectedEvent.date,
            selectedEvent.venue,
            selectedEvent.totalTickets,
            selectedEvent.pricePerTicket,
            selectedEvent.ticketsSold
        );
    }

    

    function getTicketOwner(uint256 eventId, uint256 ticketId)
        external
        view
        returns (address)
    {
        Ticket[] storage tickets = eventTickets[eventId];
        require(ticketId < tickets.length, "Invalid ticket ID");

        Ticket storage ticket = tickets[ticketId];
        return ticket.owner;
    }
}

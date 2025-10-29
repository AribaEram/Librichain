contract Librichain {

    struct Book {
        uint256 id;
        string title;
        address owner;
        address currentBorrower;
        bool isBorrowed;
    }

    uint256 public nextBookId;
    mapping(uint256 => Book) public books;
    mapping(address => uint256[]) public ownedBooks;

    event BookAdded(uint256 indexed bookId, string title, address indexed owner);
    event BookBorrowed(uint256 indexed bookId, address indexed borrower);
    event BookReturned(uint256 indexed bookId, address indexed borrower);

    /**
     * @notice Add a new book to Librichain.
     * @param _title The title of the book.
     */
    function addBook(string memory _title) external {
        uint256 bookId = nextBookId++;
        books[bookId] = Book({
            id: bookId,
            title: _title,
            owner: msg.sender,
            currentBorrower: address(0),
            isBorrowed: false
        });
        ownedBooks[msg.sender].push(bookId);
        emit BookAdded(bookId, _title, msg.sender);
    }

    /**
     * @notice Borrow a book if it’s available.
     * @param _bookId The ID of the book to borrow.
     */
    function borrowBook(uint256 _bookId) external {
        Book storage book = books[_bookId];
        require(book.owner != address(0), "Book does not exist");
        require(!book.isBorrowed, "Book already borrowed");
        require(book.owner != msg.sender, "Owner cannot borrow own book");

        book.isBorrowed = true;
        book.currentBorrower = msg.sender;

        emit BookBorrowed(_bookId, msg.sender);
    }

    /**
     * @notice Return a borrowed book.
     * @param _bookId The ID of the book to return.
     */
    function returnBook(uint256 _bookId) external {
        Book storage book = books[_bookId];
        require(book.isBorrowed, "Book is not borrowed");
        require(book.currentBorrower == msg.sender, "You are not the borrower");

        book.isBorrowed = false;
        book.currentBorrower = address(0);

        emit BookReturned(_bookId, msg.sender);
    }

    /**
     * @notice View all books owned by a specific address.
     */
    function getOwnedBooks(address _owner) external view returns (uint256[] memory) {
        return ownedBooks[_owner];
    }

    /**
     * @notice Fetch full details of a book.
     */
    function getBook(uint256 _bookId) external view returns (
        string memory title,
        address owner,
        address borrower,
        bool isBorrowed
    ) {
        Book memory b = books[_bookId];
        return (b.title, b.owner, b.currentBorrower, b.isBorrowed);
    }
}


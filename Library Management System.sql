-- Create Authors table
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(100) NOT NULL,
    BirthDate DATE,
    Nationality VARCHAR(50),
    Biography TEXT
);

-- Create Publishers table
CREATE TABLE Publishers (
    PublisherID INT PRIMARY KEY,
    PublisherName VARCHAR(100) NOT NULL,
    Location VARCHAR(100),
    FoundedDate DATE
);

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

-- Create Books table
CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ISBN VARCHAR(20),
    AuthorID INT,
    PublisherID INT,
    PublishedDate DATE,
    Genre VARCHAR(50),
    CategoryID INT,
    StockQuantity INT NOT NULL,
    AvailableQuantity INT NOT NULL,
    CONSTRAINT FK_Author FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    CONSTRAINT FK_Publisher FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID),
    CONSTRAINT FK_Category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Borrowers table
CREATE TABLE Borrowers (
    BorrowerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    RegistrationDate DATE NOT NULL
);

-- Create Transactions table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    BookID INT,
    BorrowerID INT,
    CheckoutDate DATE NOT NULL,
    ReturnDate DATE,
    IsReturned BOOLEAN DEFAULT false,
    FineAmount DECIMAL(10, 2),
    CONSTRAINT FK_Book_Transaction FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT FK_Borrower_Transaction FOREIGN KEY (BorrowerID) REFERENCES Borrowers(BorrowerID)
);

-- Create Reservations table
CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY,
    BookID INT,
    BorrowerID INT,
    ReservationDate DATE NOT NULL,
    CONSTRAINT FK_Book_Reservation FOREIGN KEY (BookID) REFERENCES Books(BookID),
    CONSTRAINT FK_Borrower_Reservation FOREIGN KEY (BorrowerID) REFERENCES Borrowers(BorrowerID)
);

-- Create Fines table
CREATE TABLE Fines (
    FineID INT PRIMARY KEY,
    TransactionID INT,
    Amount DECIMAL(10, 2) NOT NULL,
    Paid BOOLEAN DEFAULT false,
    CONSTRAINT FK_Transaction_Fine FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);

-- Stored procedures for generating random data (as shown in a previous response)

-- Additional tables and relationships can be added based on your requirements

-- Stored procedures for functionalities like book checkout, return, reserve, etc.
DELIMITER //

-- Procedure to perform book checkout
CREATE PROCEDURE CheckoutBook(IN bookID INT, IN borrowerID INT)
BEGIN
    -- Check if the book is available
    IF (SELECT AvailableQuantity FROM Books WHERE BookID = bookID) > 0 THEN
        -- Update book quantity
        UPDATE Books SET AvailableQuantity = AvailableQuantity - 1 WHERE BookID = bookID;

        -- Insert transaction record
        INSERT INTO Transactions (BookID, BorrowerID, CheckoutDate) VALUES (bookID, borrowerID, CURDATE());
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not available for checkout';
    END IF;
END //

-- Procedure to perform book return
CREATE PROCEDURE ReturnBook(IN transactionID INT)
BEGIN
    -- Check if the transaction exists and is not already returned
    IF EXISTS (SELECT 1 FROM Transactions WHERE TransactionID = transactionID AND IsReturned = false) THEN
        -- Update book quantity and transaction
        UPDATE Books
        JOIN Transactions ON Books.BookID = Transactions.BookID
        SET Books.AvailableQuantity = Books.AvailableQuantity + 1,
            Transactions.IsReturned = true,
            Transactions.ReturnDate = CURDATE()
        WHERE Transactions.TransactionID = transactionID;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid transaction or book already returned';
    END IF;
END //

-- Procedure to reserve a book
CREATE PROCEDURE ReserveBook(IN bookID INT, IN borrowerID INT)
BEGIN
    -- Check if the book is available
    IF (SELECT AvailableQuantity FROM Books WHERE BookID = bookID) > 0 THEN
        -- Insert reservation record
        INSERT INTO Reservations (BookID, BorrowerID, ReservationDate) VALUES (bookID, borrowerID, CURDATE());
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not available for reservation';
    END IF;
END //

DELIMITER ;

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

-- Procedure to generate random date within a range
DELIMITER //

CREATE PROCEDURE GenerateRandomDate(IN startDate DATE, IN endDate DATE, OUT randomDate DATE)
BEGIN
    SET randomDate = DATE_ADD(startDate, INTERVAL ROUND(RAND() * DATEDIFF(endDate, startDate)) DAY);
END //

DELIMITER ;

-- Procedure to generate random data for Authors
DELIMITER //

CREATE PROCEDURE GenerateRandomAuthors(IN count INT)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= count DO
        INSERT INTO Authors (AuthorName, BirthDate, Nationality, Biography)
        VALUES 
            (CONCAT('Author', i), GenerateRandomDate('1800-01-01', '2000-12-31'), 'Nationality' || i, 'Biography' || i);

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-- Procedure to generate random data for Publishers
DELIMITER //

CREATE PROCEDURE GenerateRandomPublishers(IN count INT)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= count DO
        INSERT INTO Publishers (PublisherName, Location, FoundedDate)
        VALUES 
            (CONCAT('Publisher', i), 'Location' || i, GenerateRandomDate('1900-01-01', '2022-12-31'));

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-- Procedure to generate random data for Categories
DELIMITER //

CREATE PROCEDURE GenerateRandomCategories(IN count INT)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= count DO
        INSERT INTO Categories (CategoryName)
        VALUES 
            (CONCAT('Category', i));

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-- Procedure to generate random data for Books
DELIMITER //

CREATE PROCEDURE GenerateRandomBooks(IN count INT)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= count DO
        INSERT INTO Books (Title, ISBN, AuthorID, PublisherID, PublishedDate, Genre, CategoryID, StockQuantity)
        VALUES 
            (CONCAT('Book', i), CONCAT('ISBN', i), ROUND(RAND() * count), ROUND(RAND() * count), 
            GenerateRandomDate('1900-01-01', '2022-12-31'), 'Genre' || i, ROUND(RAND() * count), ROUND(RAND() * 50));

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-- Procedure to generate random data for Borrowers
DELIMITER //

CREATE PROCEDURE GenerateRandomBorrowers(IN count INT)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= count DO
        INSERT INTO Borrowers (FirstName, LastName, Email, Phone, RegistrationDate)
        VALUES 
            (CONCAT('Borrower', i), 'LastName' || i, CONCAT('email', i, '@example.com'), 
            CONCAT('+1234567', i), GenerateRandomDate('2020-01

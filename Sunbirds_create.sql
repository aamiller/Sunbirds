-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2018-10-29 17:22:10.978

-- tables
-- Table: CustomerCartLines_T
CREATE TABLE CustomerCartLines_T (
    CartLineID int  NOT NULL,
    Customers_T_CustomerID int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    Quantity int  NOT NULL,
    CONSTRAINT CustomerCartLines_T_pk PRIMARY KEY (CartLineID)
);

-- Table: Customers_T
CREATE TABLE Customers_T (
    CustomerID int  NOT NULL,
    CustomerName varchar(50)  NOT NULL,
    CustomerAddress varchar(50)  NOT NULL,
    CustomerCity varchar(50)  NOT NULL,
    CustomerState varchar(2)  NOT NULL,
    CustomerPostalCode varchar(10)  NOT NULL,
    CONSTRAINT Customers_T_pk PRIMARY KEY (CustomerID)
);

-- Table: Inventory_T
CREATE TABLE Inventory_T (
    InventoryID int  NOT NULL,
    Quantity int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    CONSTRAINT Inventory_T_pk PRIMARY KEY (InventoryID)
);

-- Table: OrderLine_T
CREATE TABLE OrderLine_T (
    OrderLineID int  NOT NULL,
    OrderID int  NOT NULL,
    OrderedQuantity int  NOT NULL,
    Order_T_OrderID int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    CONSTRAINT OrderLine_T_pk PRIMARY KEY (OrderLineID)
);

-- Table: Order_T
CREATE TABLE Order_T (
    OrderID int  NOT NULL,
    CustomerID int  NOT NULL,
    OrderDate date  NOT NULL,
    FulfillmentDate date  NOT NULL,
    OrderCost int  NOT NULL,
    CONSTRAINT Order_T_pk PRIMARY KEY (OrderID)
);

-- Table: Products_T
CREATE TABLE Products_T (
    ProductID int  NOT NULL,
    ProductName varchar(255)  NOT NULL,
    ProductDescription int  NOT NULL,
    is_sunglass bool  NOT NULL,
    ProductStandardPrice money  NULL,
    is_available bool  NOT NULL,
    CONSTRAINT Products_T_pk PRIMARY KEY (ProductID)
);

-- foreign keys
-- Reference: CustomerCartLines_T_Customers_T (table: CustomerCartLines_T)
ALTER TABLE CustomerCartLines_T ADD CONSTRAINT CustomerCartLines_T_Customers_T
    FOREIGN KEY (Customers_T_CustomerID)
    REFERENCES Customers_T (CustomerID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: CustomerCartLines_T_Products_T (table: CustomerCartLines_T)
ALTER TABLE CustomerCartLines_T ADD CONSTRAINT CustomerCartLines_T_Products_T
    FOREIGN KEY (Products_T_ProductID)
    REFERENCES Products_T (ProductID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Inventory_T_Products_T (table: Inventory_T)
ALTER TABLE Inventory_T ADD CONSTRAINT Inventory_T_Products_T
    FOREIGN KEY (Products_T_ProductID)
    REFERENCES Products_T (ProductID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: OrderLine_T_Order_T (table: OrderLine_T)
ALTER TABLE OrderLine_T ADD CONSTRAINT OrderLine_T_Order_T
    FOREIGN KEY (Order_T_OrderID)
    REFERENCES Order_T (OrderID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: OrderLine_T_Products_T (table: OrderLine_T)
ALTER TABLE OrderLine_T ADD CONSTRAINT OrderLine_T_Products_T
    FOREIGN KEY (Products_T_ProductID)
    REFERENCES Products_T (ProductID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.


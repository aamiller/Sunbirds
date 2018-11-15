-- TODO: Customer_T partition by state @PAUL

-- tables
-- Table: CustomerCartLines_T
CREATE TABLE CustomerCartLines_T (
    CartLineID int  NOT NULL,
    Customers_T_CustomerID int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    Quantity int  NOT NULL,
    CONSTRAINT CustomerCartLines_T_pk PRIMARY KEY (CartLineID)
);

CLUSTER CustomerCartLines_T using CustomerCartLines_T_pk;

-- Table: Customers_T
CREATE TABLE Customers_T (
    CustomerID int  NOT NULL,
    CustomerName varchar(50)  NOT NULL,
    CustomerAddress varchar(50)  NOT NULL,
    CustomerCity varchar(50)  NOT NULL,
    CustomerState varchar(2)  NOT NULL,
    CustomerPostalCode varchar(10)  NOT NULL,
    CustomerEmail varchar(255)  NOT NULL,
    CONSTRAINT Customers_T_pk PRIMARY KEY (CustomerID)
);

CREATE INDEX Customers_T_CustomerID_idx on Customers_T (CustomerID ASC);

-- Table: FrameType_T
CREATE TABLE FrameType_T (
    FrameTypeID int  NOT NULL,
    FrameColorDescription varchar(255)  NOT NULL,
    FrameShapeDescription varchar(255)  NOT NULL,
    CONSTRAINT FrameType_T_pk PRIMARY KEY (FrameTypeID)
);

CREATE INDEX FrameType_T_FrameTypeID_idx on FrameType_T (FrameTypeID ASC);

CREATE INDEX FrameType_T_FrameColorDescription_idx on FrameType_T (FrameColorDescription ASC);

CREATE INDEX FrameType_T_FrameShapeDescription_idx on FrameType_T (FrameShapeDescription ASC);

-- Table: Inventory_T
CREATE TABLE Inventory_T (
    InventoryID int  NOT NULL,
    Quantity int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    CONSTRAINT Inventory_T_pk PRIMARY KEY (InventoryID)
);

CREATE INDEX Inventory_T_InventoryID_idx on Inventory_T (InventoryID ASC);

-- Table: OrderLine_T
CREATE TABLE OrderLine_T (
    OrderLineID int  NOT NULL,
    OrderedQuantity int  NOT NULL,
    Order_T_OrderID int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    CONSTRAINT OrderLine_T_pk PRIMARY KEY (OrderLineID)
);

CREATE INDEX OrderLine_T_OrderLineID_idx on OrderLine_T (OrderLineID ASC);

-- Table: Order_T
CREATE TABLE Order_T (
    OrderID int  NOT NULL,
    OrderDate date  NOT NULL,
    FulfillmentDate date  NOT NULL,
    OrderCost int  NOT NULL,
    Customers_T_CustomerID int  NOT NULL,
    CONSTRAINT Order_T_pk PRIMARY KEY (OrderID)
)
    PARTITION BY RANGE (OrderDate);

CREATE INDEX Order_T_OrderID_idx on Order_T (OrderID ASC);

CREATE INDEX Order_T_idx_OrderDate_idx on Order_T (OrderDate ASC);

-- Table: Products_T
CREATE TABLE Products_T (
    ProductID int  NOT NULL,
    ProductName varchar(255)  NOT NULL,
    ProductDescription int  NOT NULL,
    is_sunglass bool  NOT NULL,
    ProductStandardPrice money  NULL,
    is_available bool  NOT NULL,
    photoURL int  NOT NULL,
    FrameType_T_FrameTypeID int  NOT NULL,
    CONSTRAINT Products_T_pk PRIMARY KEY (ProductID)
);

CREATE INDEX Products_T_ProductID_idx on Products_T (ProductID ASC);

CREATE INDEX Products_T_ProductName_idx on Products_T (ProductName ASC);

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

-- Reference: Order_T_Customers_T (table: Order_T)
ALTER TABLE Order_T ADD CONSTRAINT Order_T_Customers_T
    FOREIGN KEY (Customers_T_CustomerID)
    REFERENCES Customers_T (CustomerID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Products_T_FrameType_T (table: Products_T)
ALTER TABLE Products_T ADD CONSTRAINT Products_T_FrameType_T
    FOREIGN KEY (FrameType_T_FrameTypeID)
    REFERENCES FrameType_T (FrameTypeID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Add partitions
CREATE TABLE Order_T.orders_2015
    PARTITION
    OF Order_T FOR VALUES FROM ('2015-01-01') TO ('2015-12-31');

CREATE TABLE Order_T.orders_2016
    PARTITION
    OF Order_T FOR VALUES FROM ('2016-01-01') TO ('2016-12-31');
    
CREATE TABLE Order_T.orders_2017
    PARTITION
    OF Order_T FOR VALUES FROM ('2017-01-01') TO ('2017-12-31');
    
CREATE TABLE Order_T.orders_2018
    PARTITION
    OF Order_T FOR VALUES FROM ('2018-01-01') TO ('2018-12-31');


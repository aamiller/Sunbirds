-- Testing tables
Create SCHEMA sunbirds;
-- tables
-- Table: CustomerCartLines_T
CREATE TABLE sunbirds.CustomerCartLines_T (
    CartLineID int  NOT NULL,
    Customers_T_CustomerID int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    Quantity int  NOT NULL,
    CONSTRAINT CustomerCartLines_T_pk PRIMARY KEY (CartLineID)
);

-- Table: Customers_T
CREATE TABLE sunbirds.Customers_T (
    CustomerID int  NOT NULL,
    CustomerName varchar(50)  NOT NULL,
    CustomerAddress varchar(50)  NOT NULL,
    CustomerCity varchar(50)  NOT NULL,
    CustomerState varchar(2)  NOT NULL,
    CustomerPostalCode varchar(10)  NOT NULL,
    CustomerEmail varchar(255)  NOT NULL,
    CONSTRAINT Customers_T_pk PRIMARY KEY (CustomerID)
);

-- Table: FrameType_T
CREATE TABLE sunbirds.FrameType_T (
    FrameTypeID int  NOT NULL,
    FrameColorDescription varchar(255)  NOT NULL,
    FrameShapeDescription varchar(255)  NOT NULL,
    CONSTRAINT FrameType_T_pk PRIMARY KEY (FrameTypeID)
);

-- Table: Inventory_T
CREATE TABLE sunbirds.Inventory_T (
    InventoryID int  NOT NULL,
    Quantity int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    CONSTRAINT Inventory_T_pk PRIMARY KEY (InventoryID)
);

-- Table: OrderLine_T
CREATE TABLE sunbirds.OrderLine_T (
    OrderLineID int  NOT NULL,
    OrderedQuantity int  NOT NULL,
    Order_T_OrderID int  NOT NULL,
    Products_T_ProductID int  NOT NULL,
    CONSTRAINT OrderLine_T_pk PRIMARY KEY (OrderLineID)
);

-- Table: Order_T
CREATE TABLE sunbirds.Order_T (
    OrderID int  NOT NULL,
    OrderDate date  NOT NULL,
    FulfillmentDate date  NOT NULL,
    OrderCost int  NOT NULL,
    Customers_T_CustomerID int  NOT NULL,
    CONSTRAINT Order_T_pk PRIMARY KEY (OrderID)
);

-- Table: Products_T
CREATE TABLE sunbirds.Products_T (
    ProductID int  NOT NULL,
    ProductName varchar(255)  NOT NULL,
    ProductDescription varchar(255)  NOT NULL,
    is_sunglass bool  NOT NULL,
    ProductStandardPrice money  NULL,
    can_be_sold bool  NOT NULL, -- Can be true while inventory is 0. Denotes if a product even if it has inventory is available for sale.
    photoURL varchar(255)  NOT NULL,
    FrameType_T_FrameTypeID int  NOT NULL,
    CONSTRAINT Products_T_pk PRIMARY KEY (ProductID)
);

-- foreign keys
-- Reference: CustomerCartLines_T_Customers_T (table: CustomerCartLines_T)
ALTER TABLE sunbirds.CustomerCartLines_T ADD CONSTRAINT CustomerCartLines_T_Customers_T
    FOREIGN KEY (Customers_T_CustomerID)
    REFERENCES sunbirds.Customers_T (CustomerID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: CustomerCartLines_T_Products_T (table: CustomerCartLines_T)
ALTER TABLE sunbirds.CustomerCartLines_T ADD CONSTRAINT CustomerCartLines_T_Products_T
    FOREIGN KEY (Products_T_ProductID)
    REFERENCES sunbirds.Products_T (ProductID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Inventory_T_Products_T (table: Inventory_T)
ALTER TABLE sunbirds.Inventory_T ADD CONSTRAINT Inventory_T_Products_T
    FOREIGN KEY (Products_T_ProductID)
    REFERENCES sunbirds.Products_T (ProductID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: OrderLine_T_Order_T (table: OrderLine_T)
ALTER TABLE sunbirds.OrderLine_T ADD CONSTRAINT OrderLine_T_Order_T
    FOREIGN KEY (Order_T_OrderID)
    REFERENCES sunbirds.Order_T (OrderID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: OrderLine_T_Products_T (table: OrderLine_T)

ALTER TABLE sunbirds.OrderLine_T ADD CONSTRAINT OrderLine_T_Products_T
    FOREIGN KEY (Products_T_ProductID)
    REFERENCES sunbirds.Products_T (ProductID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Order_T_Customers_T (table: Order_T)
ALTER TABLE sunbirds.Order_T ADD CONSTRAINT Order_T_Customers_T
    FOREIGN KEY (Customers_T_CustomerID)
    REFERENCES sunbirds.Customers_T (CustomerID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: Products_T_FrameType_T (table: Products_T)
ALTER TABLE sunbirds.Products_T ADD CONSTRAINT Products_T_FrameType_T
    FOREIGN KEY (FrameType_T_FrameTypeID)
    REFERENCES sunbirds.FrameType_T (FrameTypeID)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of tables

CREATE FUNCTION can_be_sold_check() RETURNS TRIGGER AS $can_be_sold_check$
BEGIN
 IF NEW.can_be_sold IS FALSE THEN
    RAISE NOTICE 'All products with ID % have been removed from customer carts.', NEW.ProductID;
    DELETE FROM sunbirds.CustomerCartLines_T WHERE Products_T_ProductID=NEW.ProductID;
 END IF;
 RETURN NEW;
END;
$can_be_sold_check$ LANGUAGE plpgsql;

CREATE TRIGGER can_be_sold_check
BEFORE INSERT OR UPDATE ON sunbirds.Products_T 
FOR EACH ROW EXECUTE PROCEDURE can_be_sold_check();

INSERT INTO sunbirds.FrameType_T(frametypeid, FrameColorDescription, FrameShapeDescription) values (1, 'red', 'oval');

INSERT INTO sunbirds.Products_t(ProductID, ProductName, ProductDescription, 
                                is_sunglass, ProductStandardPrice, can_be_sold, photoURL, FrameType_T_FrameTypeID)
                                VALUES (1, 'Name', 'd1', TRUE, 100.00, TRUE, 'a', 1);
                                
INSERT INTO sunbirds.Products_t(ProductID, ProductName, ProductDescription, 
                                is_sunglass, ProductStandardPrice, can_be_sold, photoURL, FrameType_T_FrameTypeID)
                                VALUES (2, 'Name2', 'd2', TRUE, 120.00, TRUE, 'b', 1);
                                
INSERT INTO sunbirds.Customers_T(CustomerID, CustomerName, CustomerAddress, 
                                CustomerCity, CustomerState, CustomerPostalCode, CustomerEmail)
                                VALUES(1, 'custname', 'custaddr', 'custcity', 'WA', '91393', 'a@b.org');

INSERT INTO sunbirds.CustomerCartLines_T(CartLineID, Customers_T_CustomerID, Products_T_ProductID, Quantity) 
                                            VALUES(1, 1, 1, 1);
                                            
INSERT INTO sunbirds.CustomerCartLines_T(CartLineID, Customers_T_CustomerID, Products_T_ProductID, Quantity) 
                                            VALUES(2, 1, 2, 1);
                                            
-- Customer has both products in cart                                           
SELECT * FROM sunbirds.CustomerCartLines_T;

SELECT * FROM sunbirds.Products_t;

-- Update 2nd product so it is not for sale, it disappears from cartlines
UPDATE sunbirds.Products_t 
SET can_be_sold=FALSE
WHERE ProductID=2;

-- Product 2 is now gone                                        
SELECT * FROM sunbirds.CustomerCartLines_T;

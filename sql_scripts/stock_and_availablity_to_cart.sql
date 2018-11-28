/*
By: Muhammad Hariz & Claire Kim
INFO 430

*/


----- for sunbirds

/*
Quantity in cart check function. A trigger function that raises exception if a customer is buying in zero quantity
of a product*/
CREATE OR REPLACE FUNCTION quantity_check()
  RETURNS TRIGGER AS $quantity_check$
BEGIN
  IF NEW.quantity <= 0 THEN
    RAISE EXCEPTION '% order quantity cannot be zero or negative %', NEW.quantity, NEW.products_t_productid;
  END IF;
  RETURN NEW;
END; $quantity_check$ LANGUAGE plpgsql;


----- trigger section, for schema
CREATE TRIGGER quantity_check
  BEFORE INSERT OR UPDATE ON sunbirds.customercartlines_t
  FOR EACH ROW EXECUTE PROCEDURE quantity_check();


----- trigger section, for non-schema
CREATE TRIGGER quantity_check
  BEFORE INSERT OR UPDATE ON customercartlines_t
  FOR EACH ROW EXECUTE PROCEDURE quantity_check();




----- testing

----- adding a dummy customer
INSERT INTO sunbirds.products_t (productid, productname, productdescription, is_sunglass, productstandardprice, can_be_sold, frame_type, color)
VALUES(1, 'Clubmaster', 22, TRUE, 50.00, TRUE, '7-MVK', 'Black');


----- adding a dummy product
INSERT INTO sunbirds.customers_t (customerid, customername, customeraddress, customercity, customerstate, customerpostalcode, customeremail)
VALUES(1, 'Muhammad', 'Happy St Ave NE', 'Renton', 'WA', '98056', 'mo@sunbirds.com');

----- adding 0 quantity product, should not work
INSERT INTO sunbirds.customercartlines_t (cartlineid, customers_t_customerid, products_t_productid, quantity)
VALUES(1, 1, 1, 0);

----- adding negative quantity product, should not work
INSERT INTO sunbirds.customercartlines_t (cartlineid, customers_t_customerid, products_t_productid, quantity)
VALUES(1, 1, 1, -1);

----- adding positive quantity products, should work
INSERT INTO sunbirds.customercartlines_t (cartlineid, customers_t_customerid, products_t_productid, quantity)
VALUES(1, 1, 1, 2);

----- checking data
SELECT * FROM sunbirds.customers_t;
SELECT * FROM sunbirds.customercartlines_t;
SELECT * FROM sunbirds.products_t;

delete from sunbirds.customercartlines_t where cartlineid = 1;


/*
A function that checks whether a customer can add a product into their cart when the product is available or sold out
*/
CREATE OR REPLACE FUNCTION availability_check()
  RETURNS TRIGGER
  AS $check_availability$
BEGIN
  IF ((SELECT can_be_sold FROM sunbirds.products_t WHERE productid = NEW.products_t_productid) = FALSE)
     OR
     ((SELECT quantity FROM sunbirds.inventory_t WHERE products_t_productid = NEW.products_t_productid) <= 0)
  THEN
    RAISE EXCEPTION 'product is not available or sold out';
  END IF;
  RETURN NEW;
END;
$check_availability$ LANGUAGE plpgsql;


------ trigger section for schema
CREATE trigger availability_check
  before insert or update on sunbirds.customercartlines_t
  FOR EACH ROW EXECUTE PROCEDURE availability_check();


-------- testing --------

----- adding product that is not available
INSERT INTO sunbirds.products_t (productid, productname, productdescription, is_sunglass, productstandardprice, can_be_sold, frame_type, color)
VALUES(2, 'Something', 21, TRUE, 50.00, FALSE, '7-MVK', 'Black');

----- adding product that is available
INSERT INTO sunbirds.products_t (productid, productname, productdescription, is_sunglass, productstandardprice, can_be_sold, frame_type, color)
VALUES(3, 'Black Shades', 23, TRUE, 50.00, TRUE, '7-MVK', 'Black');

----- adding product that is unavailable
INSERT INTO sunbirds.products_t (productid, productname, productdescription, is_sunglass, productstandardprice, can_be_sold, frame_type, color)
VALUES(4, 'Yello Shades', 24, TRUE, 50.00, FALSE, '7-MVK', 'Yellow');

----- adding inventory of 20 for available product
insert into sunbirds.inventory_t values (1, 20, 1);

----- adding inventory of 20 for unavailable product
insert into sunbirds.inventory_t values (2, 20, 2);

----- adding inventory of 0 for available product
insert into sunbirds.inventory_t values (3, 0, 3);

----- adding inventory of 0 for unavailable product
insert into sunbirds.inventory_t values (4, 0, 3);


----- adding available, in stock, product to cart, should work
insert into sunbirds.customercartlines_t values (5,1,1,1);

----- adding unavailable, in stock, product to cart, shouldn't work
insert into sunbirds.customercartlines_t values (5,1,2,1);

----- adding available, out of stock, product to cart, shouldn't work
insert into sunbirds.customercartlines_t values (5,1,3,1);

----- adding unavailable, out of stock, product to cart, shouldn't work
insert into sunbirds.customercartlines_t values (5,1,4,1);


----- check data
SELECT * FROM sunbirds.customercartlines_t WHERE customers_t_customerid = 5;

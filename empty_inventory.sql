CREATE TRIGGER inventory_cart_check
  AFTER UPDATE ON sunbirds.Inventory_T
  FOR EACH ROW EXECUTE PROCEDURE
  empty_cart();


CREATE OR REPLACE FUNCTION empty_cart()
  RETURNS TRIGGER AS $$
BEGIN
  IF NEW.Quantity <= 0
  THEN DELETE from sunbirds.CustomerCartLines_T c WHERE c.Products_T_ProductID = NEW.Products_T_ProductID;
  END IF;
  RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

INSERT INTO sunbirds.frametype_t(frametypeid, framecolordescription, frameshapedescription)
VALUES (1, 'Blue', 'Round')

INSERT INTO sunbirds.products_t(productid, productname, productdescription, is_sunglass, productstandardprice, can_be_sold, photourl, frametype_t_frametypeid)
VALUES (1, 'Sunbricks', 1, true, 100.00, true, 1, 1)

INSERT INTO sunbirds.inventory_t(inventoryid, quantity, products_t_productid) VALUES (1, 1, 1)

INSERT INTO sunbirds.customers_t(customerid, customername, customeraddress, customercity, customerstate, customerpostalcode, customeremail)
VALUES (1, 'Sean', '1110 Nike', 'San Diego', 'CA', '98105', 'cean.com')

INSERT INTO sunbirds.customercartlines_t(cartlineid, customers_t_customerid, products_t_productid, quantity)
VALUES (1, 1, 1, 1)

-- SELECT * from sunbirds.inventory_t;
--SELECT * from sunbirds.customercartlines_t;

UPDATE sunbirds.inventory_t
SET quantity = 0
WHERE inventoryid = 1
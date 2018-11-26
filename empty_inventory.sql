CREATE TRIGGER inventory_cart_check
  AFTER UPDATE ON Inventory_T
  FOR EACH ROW EXECUTE PROCEDURE
  empty_cart();


CREATE OR REPLACE FUNCTION empty_cart()
  RETURNS TRIGGER AS $$
BEGIN
  IF NEW.Quantity <= 0
  THEN DELETE from CustomerCartLines_T c WHERE c.Products_T_ProductID = NEW.Products_T_ProductID;
  END IF;
  RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';
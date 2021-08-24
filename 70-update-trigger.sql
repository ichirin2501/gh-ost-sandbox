USE test;

SET SQL_SAFE_UPDATES = 0;
SET SQL_LOG_BIN = OFF;

STOP SLAVE;

UPDATE banks SET account_number=NULL;

DELIMITER $$
CREATE TRIGGER banks_insert BEFORE INSERT ON banks
 FOR EACH ROW
thisTrigger: BEGIN
   IF (NEW.account_number IS NOT NULL) THEN
     SET NEW.account_number = NULL;
   END IF;
 END;
$$

CREATE TRIGGER banks_update BEFORE UPDATE ON banks
 FOR EACH ROW
thisTrigger: BEGIN
   IF (NEW.account_number IS NOT NULL AND NEW.account_number != ifnull(OLD.account_number, '')) THEN
     SET NEW.account_number = NULL;
   END IF;
 END;
$$

DELIMITER ;

START SLAVE;

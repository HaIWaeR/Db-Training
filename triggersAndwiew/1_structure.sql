CREATE TYPE status_enum AS ENUM ('available', 'rented', 'under_maintenance');

CREATE TABLE equipment_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40) NOT NULL
);

CREATE TABLE ski_inventory (
    id SERIAL PRIMARY KEY,
    equipment_name VARCHAR(60) NOT NULL,
    equipment_type INT,
    size VARCHAR(50),
    status status_enum NOT NULL,
    FOREIGN KEY (equipment_type) REFERENCES equipment_type(id) ON DELETE SET NULL
);

CREATE TABLE rentals (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    customer_phone VARCHAR(50) NOT NULL,
    rental_start TIMESTAMP NOT NULL,
    rental_end TIMESTAMP NOT NULL,
    actual_return_time TIMESTAMP,
    ski_inventory INT,
    FOREIGN KEY (ski_inventory) REFERENCES ski_inventory(id) ON DELETE CASCADE
);

CREATE OR REPLACE PROCEDURE start_rental(
    in_customer_name VARCHAR,
    in_customer_phone VARCHAR,
    in_equipment_id INT,
    in_rental_hours INT
)

LANGUAGE plpgsql
AS $$
DECLARE
    current_equipment_status status_enum;
BEGIN
    SELECT status INTO current_equipment_status
    FROM ski_inventory
    WHERE id = in_equipment_id;

    IF current_equipment_status IS NULL THEN
        RAISE EXCEPTION 'Equipment with ID % does not exist', in_equipment_id;
    END IF;

    IF current_equipment_status != 'available' THEN
        RAISE EXCEPTION 'The equipment is not available for rental. Current status: %', current_equipment_status;
    END IF;

    INSERT INTO rentals (customer_name, customer_phone, rental_start, rental_end, ski_inventory)
    VALUES (
        in_customer_name,
        in_customer_phone,
        NOW(),
        NOW() + INTERVAL '1 hour' * in_rental_hours,
        in_equipment_id
    );

    UPDATE ski_inventory
    SET status = 'rented'
    WHERE id = in_equipment_id;

    RAISE NOTICE 'Rental started successfully for customer % on equipment ID %', in_customer_name, in_equipment_id;

END;
$$;

CREATE OR REPLACE FUNCTION check_equipment_availability()
RETURNS TRIGGER 
LANGUAGE plpgsql

AS $$
DECLARE
    equipment_status status_enum;
BEGIN

    SELECT status INTO equipment_status
    FROM ski_inventory 
    WHERE id = NEW.ski_inventory;
    
    IF equipment_status IS NULL THEN
        RAISE EXCEPTION 'Cannot create rental: Equipment with ID % does not exist', NEW.ski_inventory;
    END IF;
    
    IF equipment_status != 'available' THEN
        RAISE EXCEPTION 'Cannot create rental: Equipment with ID % is not available. Current status: %', 
                        NEW.ski_inventory, equipment_status;
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER prevent_double_renting
    BEFORE INSERT ON rentals
    FOR EACH ROW
    EXECUTE FUNCTION check_equipment_availability();
    
CREATE OR REPLACE VIEW current_rentals_view AS
SELECT 
    r.id AS rental_id,
    si.equipment_name AS inventory_name,
    et.name AS equipment_type,
    r.customer_name,
    r.customer_phone,
    r.rental_start,
    r.rental_end
FROM 
    rentals r
    JOIN ski_inventory si ON r.ski_inventory = si.id
    JOIN equipment_type et ON si.equipment_type = et.id
WHERE 
    r.actual_return_time IS NULL
ORDER BY 
    r.rental_start DESC;
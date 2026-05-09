INSERT INTO equipment_type (name)
VALUES
    ('Ski'),
    ('Snowboard'),
    ('Boots'),
    ('Helmet'),
    ('Poles'),
    ('Goggles'),
    ('Ski Suit'),
    ('Gloves'),
    ('Protection Gear'),
    ('Ski Bag');

INSERT INTO ski_inventory (equipment_name, equipment_type, size, status)
VALUES
    ('Царская элита', 1, 'M', 'available'),  
    ('Трость гендальфа', 1, 'L', 'rented'),     
    ('СабвейСёрф дсока', 2, 'S', 'under_maintenance'), 
    ('Геркулесья сила', 3, 'M', 'available'),  
    ('Батин колпак 2077', 4, 'XXXL', 'available');    

INSERT INTO rentals (customer_name, customer_phone, rental_start, rental_end, actual_return_time, ski_inventory)
VALUES
    ('Роман Сакутин', '900-185-1888', '2025-10-15 10:00:00', '2025-10-15 18:00:00', '2025-10-15 17:45:00', 2), 
    ('Папков Виталий', '922-724-9024', '2025-10-16 09:00:00', '2025-10-16 17:00:00', NULL, 1),  
    ('Марсо Эскобаро', '924-835-4035', '2025-10-17 11:00:00', '2025-10-17 16:00:00', '2025-11-17 15:20:00', 5);
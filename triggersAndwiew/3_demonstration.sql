SELECT '=== НАЧАЛЬНОЕ СОСТОЯНИЕ АКТИВНЫХ АРЕНД ===' AS info;
SELECT * FROM current_rentals_view;

SELECT '=== ДОСТУПНОЕ ОБОРУДОВАНИЕ ===' AS info;
SELECT id, equipment_name, status 
FROM ski_inventory 
WHERE status = 'available';

SELECT '=== УСПЕШНАЯ АРЕНДА (оборудование ID 4) ===' AS info;
CALL start_rental('Эльдар Жаракох', '800-555-3535', 4, 4);

SELECT '=== РЕЗУЛЬТАТ УСПЕШНОЙ АРЕНДЫ ===' AS info;
SELECT * FROM current_rentals_view WHERE customer_name = 'Эльдар Жаракох';

SELECT '=== НЕУДАЧНАЯ АРЕНДА (оборудование ID 2 уже занято) ===' AS info;
DO $$
BEGIN
    CALL start_rental('Царь Леонид', '000-000-0000', 2, 2);
EXCEPTION 
    WHEN OTHERS THEN
        RAISE NOTICE 'Ожидаемая ошибка: %', SQLERRM;
END $$;

SELECT '=== НЕУДАЧНАЯ АРЕНДА (оборудование ID 3 на обслуживании) ===' AS info;
DO $$
BEGIN
    CALL start_rental('Брат Брата', '111-222-3333', 3, 3);
EXCEPTION 
    WHEN OTHERS THEN
        RAISE NOTICE 'Ожидаемая ошибка: %', SQLERRM;
END $$;

SELECT '=== ДЕМОНСТРАЦИЯ ЗАЩИТЫ ТРИГГЕРОМ ===' AS info;
DO $$
BEGIN
    INSERT INTO rentals (customer_name, customer_phone, rental_start, rental_end, ski_inventory)
    VALUES ('Устал Придумывать', '000-000', NOW(), NOW() + INTERVAL '2 hours', 2);
EXCEPTION 
    WHEN OTHERS THEN
        RAISE NOTICE 'Триггер заблокировал вставку: %', SQLERRM;
END $$;

SELECT '=== ИТОГОВОЕ СОСТОЯНИЕ АКТИВНЫХ АРЕНД ===' AS info;
SELECT * FROM current_rentals_view;

SELECT '=== СТАТУСЫ ОБОРУДОВАНИЯ ПОСЛЕ ДЕМОНСТРАЦИИ ===' AS info;
SELECT id, equipment_name, status 
FROM ski_inventory 
ORDER BY id;
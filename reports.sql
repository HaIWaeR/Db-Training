-- Отчет о всех таблицах

SELECT 
    t.table_name AS "Имя таблицы",
    c.column_name AS "Столбец",
    c.data_type AS "Тип данных",
    c.character_maximum_length AS "Макс. длина",
    c.is_nullable AS "Может быть NULL",
    c.column_default AS "Значение по умолчанию"
FROM information_schema.tables t
JOIN information_schema.columns c ON t.table_name = c.table_name 
    AND t.table_schema = c.table_schema
WHERE t.table_schema = 'public'          
    AND t.table_type = 'BASE TABLE'      
ORDER BY t.table_name, c.ordinal_position;

-- все внешние ключи и связи
SELECT
    tc.table_name AS "Таблица",
    kcu.column_name AS "Столбец FK",
    ccu.table_name AS "Связанная таблица",
    ccu.column_name AS "Связанный столбец",
    tc.constraint_name AS "Имя ограничения"
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;


-- размер таблицы в мегабайтах
SELECT 
    schemaname AS "Схема",
    tablename AS "Таблица",
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS "Общий размер",
    pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) AS "Размер данных",
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename) - 
                   pg_relation_size(schemaname || '.' || tablename)) AS "Размер индексов"
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;



cd C:\Program Files\PostgreSQL\18\bin

pg_dump -U postgres -d CodeWars -f C:\backup\codewars_backup.sql



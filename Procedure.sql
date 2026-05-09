CREATE OR REPLACE PROCEDURE submit_citizen_appeal(

	p_passport_details VARCHAR(100),
	p_contact_phone VARCHAR(20),
	p_residential_address TEXT,
	p_email VARCHAR(100),

	p_appeal_description TEXT,

	p_responsible_employee_id INTEGER
)

LANGUAGE plpgsql
As $$
DECLARE
	v_citizen_id INTEGER;
	v_appeal_number VARCHAR(20);
	v_next_number INTEGER;
	v_appeal_id INTEGER;
	
BEGIN 
	SELECT id INTO v_citizen_id 
	FROM citizen 
	WHERE passport_details = p_passport_details;

	IF v_citizen_id IS NULL THEN
    	INSERT INTO citizen (passport_details, contact_phone, residential_address, email)
        VALUES (p_passport_details, p_contact_phone, p_residential_address, p_email)
        RETURNING id INTO v_citizen_id;

		RAISE NOTICE 'Создан новый гражданин с ID: %', v_citizen_id;
    ELSE
        RAISE INFO 'Найден существующий гражданин с ID: %', v_citizen_id;
    END IF;

	SELECT COALESCE(MAX(CAST(SUBSTRING(number_appeal FROM '-(\d+)$') AS INTEGER)), 0) + 1 
	INTO v_next_number 
	FROM appeal 
	WHERE number_appeal LIKE 'А-2024-%';
    
    v_appeal_number := 'А-2024-' || LPAD(v_next_number::TEXT, 4, '0');

    INSERT INTO appeal (
        number_appeal, 
        datetime_registration,
        status,
        citizen_id, 
        employee_id
    ) VALUES (
        v_appeal_number,
        CURRENT_TIMESTAMP, 
        'Открытое',
        v_citizen_id,
        p_responsible_employee_id
    )
    RETURNING id INTO v_appeal_id;

    RAISE INFO 'ОБРАЩЕНИЕ УСПЕШНО СОЗДАНО!';
    RAISE INFO 'Номер обращения: %', v_appeal_number;
    RAISE INFO 'Дата регистрации: %', CURRENT_TIMESTAMP;
    RAISE INFO 'Статус: Открытое';
    RAISE INFO 'Гражданин ID: %', v_citizen_id;
    RAISE INFO 'Ответственный сотрудник ID: %', p_responsible_employee_id;
    RAISE INFO 'Описание: %', p_appeal_description;

	EXCEPTION
	    WHEN unique_violation THEN
	        RAISE EXCEPTION 'Ошибка: Обращение с таким номером уже существует';
	    WHEN foreign_key_violation THEN
	        RAISE EXCEPTION 'Ошибка: Сотрудник с ID % не найден', p_responsible_employee_id;
	    WHEN OTHERS THEN
	        RAISE EXCEPTION 'Ошибка при создании обращения: %', SQLERRM;

END;
$$;

SELECT * FROM citizen;

CALL submit_citizen_appeal(
    '4501 999999',
    '+7-800-555-35-35',
    'Москва, ул. Примерная, д. 1',
    'bigMama@mail.ru',
    'Гуляют как черти',
    1
);

CALL submit_citizen_appeal(
    '4501 999999',
    '+7-922-724-90-24',
    'Санкт-петербург, ул. Петропавлосвская, д. 20',
    'bigMama@mail.ru',
    'Я видел он там что то ищит в кустиках',
    5
);

CREATE OR REPLACE PROCEDURE hire_mvd_employee(
    p_passport_details VARCHAR(30),
    p_snils VARCHAR(14),
    p_inn VARCHAR(12),
    p_policy_oms VARCHAR(16),
    p_military_id_details VARCHAR(50),
	p_personnel_phone VARCHAR(20),
    
    p_diplom_series_number VARCHAR(30),
    p_diplom_speciality VARCHAR(50),
    p_diplom_institution VARCHAR(100),
    p_diplom_graduation_year DATE,
    
    p_department_id INTEGER,
    p_job_title_id INTEGER,
    p_rank_id INTEGER,
    p_weapon_id INTEGER,
    p_schedule_work TEXT
)

LANGUAGE plpgsql
AS $$
DECLARE
    v_employee_id INTEGER;
    v_personnel_number VARCHAR(20);
    v_case_number VARCHAR(20);
    v_next_personnel_number INTEGER;
    v_next_case_number INTEGER;

BEGIN
    IF EXISTS (SELECT 1 FROM employee WHERE passport_details = p_passport_details) THEN
        RAISE EXCEPTION 'Сотрудник с такими паспортными данными уже существует';
    END IF;
    
    IF EXISTS (SELECT 1 FROM employee WHERE snils = p_snils) THEN
        RAISE EXCEPTION 'Сотрудник с таким СНИЛС уже существует';
    END IF;
    
    IF EXISTS (SELECT 1 FROM employee WHERE inn = p_inn) THEN
        RAISE EXCEPTION 'Сотрудник с таким ИНН уже существует';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM employee WHERE personnel_number IS NOT NULL) THEN
	    v_next_personnel_number := 1;
	    v_next_case_number := 1;
	ELSE
	    SELECT COALESCE(MAX(CAST(SUBSTRING(personnel_number FROM 'ТН-(\d+)-(\d+)') AS INTEGER)), 0) + 1 
	    INTO v_next_personnel_number 
	    FROM employee 
	    WHERE personnel_number LIKE 'ТН-2024-%';
		    
	    SELECT COALESCE(MAX(CAST(SUBSTRING(case_number FROM 'ЛД-(\d+)-(\d+)') AS INTEGER)), 0) + 1 
	    INTO v_next_case_number 
	    FROM employee 
	    WHERE case_number LIKE 'ЛД-2024-%';
	END IF;

    INSERT INTO employee (
        personnel_number,
        case_number,
        passport_details,
        snils,
        inn,
        policy_oms,
        military_id_details,
        date_of_admission_to_service,
        schedule_work,
        ranks_id,
        department_id,
        job_title_id,
        weapon_id,
		personnel_phone
    ) VALUES (
        v_personnel_number,
        v_case_number,
        p_passport_details,
        p_snils,
        p_inn,
        p_policy_oms,
        p_military_id_details,
        CURRENT_DATE,
        p_schedule_work,
        p_rank_id,
        p_department_id,
        p_job_title_id,
        p_weapon_id,
		p_personnel_phone
    )
    RETURNING id INTO v_employee_id;

    INSERT INTO diplom (
        series_and_number_diplom,
        speciality,
        educational_institution,
        year_of_graduation,
        employee_id
    ) VALUES (
        p_diplom_series_number,
        p_diplom_speciality,
        p_diplom_institution,
        p_diplom_graduation_year,
        v_employee_id
    );

    RAISE INFO 'Кандитан принят на службу!';
    RAISE INFO 'Табельный номер: %', v_personnel_number;
    RAISE INFO 'Номер личного дела: %', v_case_number;
    RAISE INFO 'Дата приема на службу: %', CURRENT_DATE;
    RAISE INFO 'Сотрудник ID: %', v_employee_id;
    RAISE INFO 'Отдел ID: %', p_department_id;
    RAISE INFO 'Должность ID: %', p_job_title_id;
    RAISE INFO 'Звание ID: %', p_rank_id;
	
    IF p_weapon_id IS NOT NULL THEN
        RAISE INFO 'Табельное оружие ID: %', p_weapon_id;
    ELSE
        RAISE INFO 'Табельное оружие: не назначено';
    END IF;
END;
$$;

-- отдел
SELECT id, name_department FROM department LIMIT 5;

-- должность
SELECT id, name_job_title FROM job_title LIMIT 5;

-- звания
SELECT id, name_ranks FROM ranks LIMIT 5;

SELECT id, number_weapon, type_weapon 
FROM weapon 
WHERE id NOT IN (SELECT weapon_id FROM employee WHERE weapon_id IS NOT NULL)
LIMIT 5;

CALL hire_mvd_employee(
    '4501 888888',           				-- паспорт 
    '888-888-888-88',        				-- СНИЛС 
    '888888888888',          				-- ИНН 
    '8888888888888888',     				-- полис ОМС
    'ВБ-888888',             				-- военный билет
	'+7-999-888-88-88',                     -- телефон
    
    'БВС 888888',            				-- номер диплома
    'Правоохранительная деятельность', 		-- специальность
    'Академия МВД России',  				-- учебное заведение
    '2023-06-30',            				-- год окончания
    
    1,                      				-- отдел ID 
    1,                      				-- должность ID 
    1,                     					-- звание ID 
    1,                      				-- оружие ID 
    'Пн-Пт 8:00-17:00'       				-- график работы
);

CALL hire_mvd_employee(
    '9999 888888',           				-- паспорт 
    '999-888-888-88',        				-- СНИЛС 
    '999888888888',          				-- ИНН 
    '9998888888888888',     				-- полис ОМС
    'РФ-888888',             				-- военный билет
	'+7-999-999-88-88',                     -- телефон
    
    'БВС 888888',            				-- номер диплома
    'Правоохранительная деятельность', 		-- специальность
    'Академия МВД России',  				-- учебное заведение
    '2023-06-30',            				-- год окончания
    
    1,                      				-- отдел ID 
    1,                      				-- должность ID 
    1,                     					-- звание ID 
    1,                      				-- оружие ID 
    'Пн-Пт 8:00-17:00'       				-- график работы
);

SELECT * FROM employee ORDER BY id DESC LIMIT 1;

SELECT * FROM diplom WHERE employee_id = (SELECT MAX(id) FROM employee);


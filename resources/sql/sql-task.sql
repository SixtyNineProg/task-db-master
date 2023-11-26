1. Вывести к каждому самолету класс обслуживания и количество мест этого класса.
SELECT aircrafts_data.aircraft_code, fare_conditions, COUNT(fare_conditions) AS count_seats
FROM aircrafts_data
         JOIN seats
              ON aircrafts_data.aircraft_code = seats.aircraft_code
GROUP BY aircrafts_data.aircraft_code, fare_conditions

2. Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT aircrafts_data.model, count(seat_no)
FROM aircrafts_data
         JOIN bookings.seats s
              ON aircrafts_data.aircraft_code = s.aircraft_code
GROUP BY aircrafts_data.model
LIMIT 3

3. Найти все рейсы, которые задерживались более 2 часов
SELECT flight_no
FROM flights
WHERE actual_arrival NOTNULL
  AND actual_arrival - scheduled_arrival > '02:00'

4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
SELECT ticket_no, passenger_name, contact_data
FROM tickets
         JOIN bookings.bookings b ON b.book_ref = tickets.book_ref
WHERE ticket_no IN (SELECT ticket_no
                    FROM ticket_flights
                    WHERE fare_conditions = 'Business')
ORDER BY book_date DESC
LIMIT 10

5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT flight_no
FROM flights
WHERE flight_id NOT IN (SELECT flight_id
                        FROM ticket_flights
                        WHERE fare_conditions = 'Business')

6. Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету
SELECT DISTINCT airport_name, city
FROM airports
         JOIN flights ON airport_code = departure_airport
WHERE actual_departure IS NOT NULL
  AND scheduled_departure != actual_departure

7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
SELECT DISTINCT airport_name, count(flight_id) AS number_of_flights
FROM airports
         JOIN flights ON airport_code = departure_airport
GROUP BY airport_name
ORDER BY number_of_flights DESC

8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
SELECT flight_no
FROM flights
WHERE actual_arrival IS NOT NULL
  AND actual_arrival != scheduled_arrival

9. Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
SELECT aircrafts_data.aircraft_code, model ->> 'ru', seat_no
FROM aircrafts_data JOIN seats ON aircrafts_data.aircraft_code = seats.aircraft_code
WHERE model ->> 'ru' = 'Аэробус A321-200' AND fare_conditions != 'Economy'
ORDER BY seat_no

10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT airport_code, airport_name, city
FROM Airports
WHERE city IN (SELECT city
               FROM Airports
               GROUP BY city
               having count(*) > 1)
ORDER BY city

11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронированийSELECT count(passenger_id)
SELECT passenger_name
FROM tickets
         JOIN bookings.bookings b ON tickets.book_ref = b.book_ref
GROUP BY passenger_name
HAVING sum(total_amount) > (SELECT avg(total_amount) FROM bookings)

12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT flight_no, scheduled_departure
FROM flights
WHERE departure_airport IN (SELECT airport_code FROM airports_data WHERE city::jsonb ->> 'ru' = 'Екатеринбург')
  AND arrival_airport IN (SELECT airport_code FROM airports_data WHERE city::jsonb ->> 'ru' = 'Москва')
  AND status IN ('Scheduled', 'On Time', 'Delayed')
ORDER BY scheduled_departure DESC
LIMIT 1

13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
(SELECT *
FROM ticket_flights
ORDER BY amount desc
LIMIT 1)
UNION
(SELECT *
FROM ticket_flights
ORDER BY amount asc
LIMIT 1);

14. Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
CREATE TABLE Customers (
   id SERIAL PRIMARY KEY,
   firstName VARCHAR(50) NOT NULL,
   lastName VARCHAR(50) NOT NULL,
   email VARCHAR(50) UNIQUE NOT NULL,
   phone VARCHAR(20) NOT NULL
);

15. Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    customerId INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    CONSTRAINT fk_customer
        FOREIGN KEY (customerId)
            REFERENCES Customers (id),
    CONSTRAINT positive_quantity
        CHECK (quantity > 0)
);

16. Написать 5 insert в эти таблицы
INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('John', 'Doe', 'johndoe@example.com', '123-456-7890');

INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('Jane', 'Doe', 'janedoe@example.com', '123-456-7890');

INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('Bob', 'Smith', 'bobsmith@example.com', '123-456-7890');

INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('Alice', 'Smith', 'alicesmith@example.com', '123-456-7890');

INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('Charlie', 'Brown', 'charliebrown@example.com', '123-456-7890');

17. Удалить таблицы
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;


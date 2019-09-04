/*
Returns rentals where the amount due does not match payment made
*/
SELECT set_system_time(current_timestamp);
SELECT set_system_time('2019-09-04 00:30');
SELECT * from payment ORDER BY sys_period DESC LIMIT 1;
SELECT unpaid.*
     , unpaid.rental_cost - unpaid.paid AS owed
FROM (
         SELECT f.film_id,
                f.title,
                r.customer_id,
                f.rental_rate,
                f.replacement_cost,
                f.rental_duration,
                r.rental_date,
                r.return_date,
                sum(p.amount)::money AS paid,
                least(ceil(date_part('day', coalesce(r.return_date, current_timestamp) - r.rental_date) /
                           f.rental_duration) * f.rental_rate, f.replacement_cost)
                    ::numeric::money AS rental_cost
         FROM film_with_history f
            JOIN inventory_with_history i ON f.film_id = i.film_id
            JOIN rental_with_history r ON i.inventory_id = r.inventory_id
            LEFT JOIN payment_with_history p ON r.rental_id = p.rental_id
               AND p.sys_period @> get_system_time()
         WHERE f.sys_period @> get_system_time()
           AND i.sys_period @> get_system_time()
           AND r.sys_period @> get_system_time()
         GROUP BY f.film_id, f.title, r.customer_id, f.rental_rate, f.replacement_cost, f.rental_duration, r.rental_date, r.return_date
     ) unpaid
WHERE unpaid.rental_cost - unpaid.paid <> 0.00::money;
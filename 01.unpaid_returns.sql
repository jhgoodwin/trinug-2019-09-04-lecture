/*
Returns rentals where the amount due does not match payment made
*/
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
         FROM film f
            JOIN inventory i ON f.film_id = i.film_id
            JOIN rental r ON i.inventory_id = r.inventory_id
            LEFT JOIN payment p ON r.rental_id = p.rental_id
         GROUP BY f.film_id, r.rental_id
     ) unpaid
WHERE unpaid.rental_cost - unpaid.paid <> 0.00::money
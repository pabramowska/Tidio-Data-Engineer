select  ppv.customer_id, pp.project_id,
MAX(CASE WHEN pp.label = 'e-mail' THEN ppv.value END) AS customer_email,
MAX(CASE WHEN pp.label = 'avg_message_volume' THEN CAST(ppv.value AS DECIMAL) END) AS avg_message_volume
FROM
    rekrutacja.project_properties_values ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
JOIN (
    SELECT
        ppv.customer_id,
        ppv.property_id,
        MAX(create_dte) AS latest_create_dte
    FROM
        rekrutacja.project_properties_values as ppv
    GROUP BY
        customer_id, property_id
) latest_values ON ppv.customer_id = latest_values.customer_id
                 AND ppv.property_id = latest_values.property_id
                 AND ppv.create_dte = latest_values.latest_create_dte
GROUP BY
    pp.project_id,
    ppv.customer_id
HAVING
    avg_message_volume > 5000
select  ppv.customer_id, pp.project_id, customers_email.customer_email,
MAX(CASE WHEN pp.label = 'e-mail' THEN ppv.value END) AS customer_email,
MAX(CASE WHEN pp.label = 'avg_message_volume' THEN CAST(ppv.value AS DECIMAL) END) AS avg_message_volume,
MAX(CASE WHEN pp.label = 'estimated_client_volume_usd' THEN CAST(ppv.value AS DECIMAL) END) AS estimated_client_volume_usd,
MAX(CASE WHEN pp.label = 'plan' THEN ppv.value END) AS plan,
MAX(CASE WHEN pp.label = 'interested_in_product' THEN ppv.value END) AS interested_in_product
FROM
    rekrutacja.project_properties_values ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
JOIN(
	SELECT ppv.customer_id, (CASE WHEN pp.label = 'e-mail' THEN ppv.value END) AS customer_email, 
    row_number() over (PARTITION BY ppv.customer_id order by ppv.create_dte desc) as row_num
FROM rekrutacja.project_properties_values as ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
WHERE pp.label = 'e-mail' and ppv.customer_id) customers_email
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
    ppv.customer_id,
    customers_email.customer_email
HAVING
    avg_message_volume > 5000 AND
    estimated_client_volume_usd > 1000
    AND plan = 'Free'
    AND interested_in_product = 'YES'

    


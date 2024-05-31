select  ppv.customer_id,
MAX(CASE WHEN pp.label = 'e-mail' THEN ppv.value END) AS customer_email

FROM
    rekrutacja.project_properties_values ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
GROUP BY
	customer_id
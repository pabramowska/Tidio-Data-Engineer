CREATE VIEW rekrutacja.marketing_dataset AS
select  ppv.customer_id, pp.project_id, email.customer_email, volume.avg_message_volume, usd.estimated_client_volume_usd,plan.plan, intr.interested_in_product
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
WHERE pp.label = 'e-mail' and ppv.customer_id) email ON ppv.customer_id = email.customer_id AND email.row_num = 1        
JOIN(
	SELECT ppv.customer_id, (CASE WHEN pp.label = 'avg_message_volume' THEN CAST(ppv.value AS DECIMAL) END) AS avg_message_volume, 
    row_number() over (PARTITION BY ppv.customer_id order by ppv.create_dte desc) as row_num
FROM rekrutacja.project_properties_values as ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
WHERE pp.label = 'avg_message_volume' and ppv.customer_id) volume ON ppv.customer_id = volume.customer_id AND volume.row_num = 1       
JOIN(
	SELECT ppv.customer_id, (CASE WHEN pp.label = 'estimated_client_volume_usd' THEN CAST(ppv.value AS DECIMAL) END) AS estimated_client_volume_usd, 
    row_number() over (PARTITION BY ppv.customer_id order by ppv.create_dte desc) as row_num
FROM rekrutacja.project_properties_values as ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
WHERE pp.label = 'estimated_client_volume_usd' and ppv.customer_id) usd ON ppv.customer_id = usd.customer_id AND usd.row_num = 1       
JOIN(
	SELECT ppv.customer_id, (CASE WHEN pp.label = 'plan' THEN ppv.value END) AS plan, 
    row_number() over (PARTITION BY ppv.customer_id order by ppv.create_dte desc) as row_num
FROM rekrutacja.project_properties_values as ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
WHERE pp.label = 'plan' and ppv.customer_id) plan ON ppv.customer_id = plan.customer_id AND plan.row_num = 1     
JOIN(
	SELECT ppv.customer_id, (CASE WHEN pp.label = 'interested_in_product' THEN ppv.value END) AS interested_in_product, 
    row_number() over (PARTITION BY ppv.customer_id order by ppv.create_dte desc) as row_num
FROM rekrutacja.project_properties_values as ppv
JOIN
    rekrutacja.project_properties pp ON ppv.property_id = pp.id 
WHERE pp.label = 'interested_in_product' and ppv.customer_id) intr ON ppv.customer_id = intr.customer_id AND intr.row_num = 1    
GROUP BY
    pp.project_id,
    ppv.customer_id,
    email.customer_email,
    volume.avg_message_volume,
    usd.estimated_client_volume_usd,
    plan.plan,
    intr.interested_in_product
HAVING
    avg_message_volume > 5000 AND
    estimated_client_volume_usd > 1000
    AND plan = 'Free'
    AND interested_in_product = 'YES';

    


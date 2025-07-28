{% macro rfm_segment_label(rfm_segment) %}
    CASE 
        WHEN {{ rfm_segment }} IN ('555', '554', '544', '545', '454', '455', '445') THEN 'Champion'
        WHEN {{ rfm_segment }} IN ('543', '444', '435', '355', '354', '345', '344', '335') THEN 'Loyal Customer'
        WHEN {{ rfm_segment }} IN ('553', '551', '552', '541', '542', '533', '532', '531', '452', '451', '442', '441', '431', '453', '433', '432', '423', '353', '352', '351', '342', '341', '333', '323') THEN 'Potential Loyalist'
        WHEN {{ rfm_segment }} IN ('512', '511', '422', '421', '412', '411', '311') THEN 'New Customer'
        WHEN {{ rfm_segment }} IN ('525', '524', '523', '522', '521', '515', '514', '513', '425', '424', '413', '414', '415', '315', '314', '313') THEN 'Promising'
        WHEN {{ rfm_segment }} IN ('535', '534', '443', '434', '343', '334', '325', '324') THEN 'Need Attention'
        WHEN {{ rfm_segment }} IN ('155', '154', '144', '214', '215', '115', '114', '113') THEN 'Cannot Lose Them'
        WHEN {{ rfm_segment }} IN ('331', '321', '312', '221', '213') THEN 'About To Sleep'
        WHEN {{ rfm_segment }} IN ('255', '254', '245', '244', '253', '252', '243', '242', '235', '234', '225', '224', '153', '152', '145', '143', '142', '135', '134', '133', '125', '124') THEN 'At Risk'
        WHEN {{ rfm_segment }} IN ('332', '322', '231', '241', '251', '233', '232', '223', '222', '132', '123', '122', '212', '211') THEN 'Hibernating'
        WHEN {{ rfm_segment }} IN ('111', '112', '121', '131', '141', '151') THEN 'Lost'
        ELSE 'Unknown'
    END
{% endmacro %}
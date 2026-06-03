{% test non_negative(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} < 0

{% endtest %}


{% test positive(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} <= 0

{% endtest %}


{% test between_zero_and_one(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} < 0
    or {{ column_name }} > 1

{% endtest %}


{% test unique_combination_of_columns(model, combination_of_columns) %}

select
    {% for column_name in combination_of_columns %}
        {{ column_name }}{% if not loop.last %},{% endif %}
    {% endfor %},
    count(*) as row_count
from {{ model }}
group by
    {% for column_name in combination_of_columns %}
        {{ column_name }}{% if not loop.last %},{% endif %}
    {% endfor %}
having count(*) > 1

{% endtest %}

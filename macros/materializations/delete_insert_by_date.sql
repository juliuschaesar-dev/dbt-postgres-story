{% materialization delete_insert_by_date, default %}

    {%- set target_relation = this.incorporate(type='table') -%}
    {%- set existing_relation = load_relation(target_relation) -%}
    {%- set temp_relation = make_temp_relation(target_relation) -%}
    {%- set date_column = config.require('date_column') -%}
    {%- set start_date = var('start_date', none) -%}
    {%- set end_date = var('end_date', none) -%}

    {% if start_date is none or end_date is none %}
        {{ exceptions.raise_compiler_error(
            "delete_insert_by_date requires --vars '{start_date: YYYY-MM-DD, end_date: YYYY-MM-DD}'"
        ) }}
    {% endif %}

    {{ run_hooks(pre_hooks) }}

    {% call statement('create_temp_relation') %}
        {{ create_table_as(true, temp_relation, sql) }}
    {% endcall %}

    {% if existing_relation is none %}

        {% call statement('create_target_relation') %}
            create table {{ target_relation }} as
            select *
            from {{ temp_relation }}
        {% endcall %}

    {% elif existing_relation.type != 'table' %}

        {% do adapter.drop_relation(existing_relation) %}

        {% call statement('replace_target_relation') %}
            create table {{ target_relation }} as
            select *
            from {{ temp_relation }}
        {% endcall %}

    {% else %}

        {% call statement('delete_target_date_range') %}
            delete from {{ target_relation }}
            where {{ date_column }} >= cast('{{ start_date }}' as date)
                and {{ date_column }} < cast('{{ end_date }}' as date)
        {% endcall %}

        {% call statement('insert_target_date_range') %}
            insert into {{ target_relation }}
            select *
            from {{ temp_relation }}
            where {{ date_column }} >= cast('{{ start_date }}' as date)
                and {{ date_column }} < cast('{{ end_date }}' as date)
        {% endcall %}

    {% endif %}

    {% do adapter.drop_relation(temp_relation) %}

    {{ run_hooks(post_hooks) }}

    {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}

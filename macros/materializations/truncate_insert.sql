{% materialization truncate_insert, default %}

    {%- set target_relation = this.incorporate(type='table') -%}
    {%- set existing_relation = load_relation(target_relation) -%}
    {%- set temp_relation = make_temp_relation(target_relation) -%}

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

        {% call statement('truncate_target_relation') %}
            truncate table {{ target_relation }}
        {% endcall %}

        {% call statement('insert_target_relation') %}
            insert into {{ target_relation }}
            select *
            from {{ temp_relation }}
        {% endcall %}

    {% endif %}

    {% do adapter.drop_relation(temp_relation) %}

    {{ run_hooks(post_hooks) }}

    {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}

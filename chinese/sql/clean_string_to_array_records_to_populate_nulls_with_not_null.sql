CREATE OR REPLACE FUNCTION maxval_chinese.clean_string_to_array_records_to_populate_nulls_with_not_null(p_string varchar,p_join_key integer) 
RETURNS TABLE(value varchar,seq int,join_key integer)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_trimmed_string varchar;
    v_delimiter varchar DEFAULT '#####';
BEGIN
    
    select trim(both  v_delimiter from trim(replace(p_string,E'\n',v_delimiter))) into v_trimmed_string ;

    RETURN QUERY
        WITH CTE AS (
        SELECT  elem,nr,
                SUM(case when trim(elem) ='-' then 0 else   1 end) over ( ORDER BY nr asc) not_null_count
        FROM unnest(string_to_array(v_trimmed_string,v_delimiter)) WITH ORDINALITY AS a(elem, nr)
        ) select  trim(first_value(elem) over (partition by not_null_count order by nr))::varchar elem, nr::int  , p_join_key::int 
        FROM CTE ;

END;
$$;

ALTER FUNCTION maxval_chinese.clean_string_to_array_records_to_populate_nulls_with_not_null(p_string varchar,p_join_key integer) OWNER TO maxval_etl_app;
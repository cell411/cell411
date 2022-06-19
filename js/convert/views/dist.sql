CREATE or replace FUNCTION public.dist(pt1 point, pt2 point) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ 
    SELECT ST_DistanceSphere(pt1::geometry,pt2::geometry)
    $$;


ALTER FUNCTION public.dist(pt1 point, pt2 point) OWNER TO parse;

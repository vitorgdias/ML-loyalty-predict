-- Monthly Active Users (MAU)
WITH tb_daily AS (

    SELECT DISTINCT
        date(substr(DtCriacao,0, 11)) AS DtDia,
        IdCliente

    FROM transacoes
    ORDER BY DtDia

),

tb_distinct_day AS (

    SELECT 
        DISTINCT DtDia as DtRef 
    FROM tb_daily

)

SELECT t1.DtRef, 
       count( distinct IdCliente) AS MAU,
       count( distinct t2.DtDia) AS qtdeDias
       
FROM tb_distinct_day AS t1

LEFT JOIN tb_daily AS t2
ON t2.DtDia <= t1.DtRef
AND julianday(t1.DtRef) - julianday(t2.DtDia) < 28

GROUP BY t1.DtRef

ORDER BY t1.DtRef DESC

LIMIT 1000
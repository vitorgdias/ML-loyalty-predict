-- curiosa -> idade < 7
-- fiel -> recencia < 7 e recencia anterior < 15
-- turista -> 7 <= recencia <= 14
-- desencantado -> 14 < recencia <= 28
-- zumbi -> recencia > 28
-- reconquistado -> recencia < 7 e 14 <= recencia anterior <= 28
-- reborn -> recencia < 7 e recencia anterior > 28

WITH tb_daily AS (
    SELECT 
        DISTINCT 
        IdCliente, 
        substr(DtCriacao, 0, 11) AS dtDia 

    FROM transacoes
    WHERE DtCriacao <= '{date}'
),

tb_idade AS (
    SELECT IdCliente, 
            -- min(dtDia) AS dtPrimTransacao,
            cast(max(julianday('{date}') - julianday(dtDia)) as int) AS qtdeDiasPrimTransacao,
            
            -- max(dtDia) AS dtUltTransacao,
            cast(min(julianday('{date}') - julianday(dtDia)) as int) AS qtdeDiasUltTransacao
    FROM tb_daily
    GROUP BY IdCliente
),

tb_rn AS (
    SELECT *, row_number() OVER (PARTITION BY IdCliente ORDER BY dtDia DESC) AS rnDia 
    FROM tb_daily
),

tb_penultima_ativacao AS (
    SELECT *, 
        CAST(julianday('{date}') - julianday(dtDia) AS int) AS qtdeDiasPenultimaTransacao 
    FROM tb_rn 
    WHERE rnDia = 2
),

tb_life_cycle AS (
    SELECT t1.*,
        t2.qtdeDiasPenultimaTransacao,
        CASE
                WHEN qtdeDiasPrimTransacao <= 7 THEN '01-CURIOSO'
                WHEN qtdeDiasUltTransacao <=7 AND qtdeDiasPenultimaTransacao <= 14 THEN '02-FIEL'
                WHEN qtdeDiasUltTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
                WHEN qtdeDiasUltTransacao BETWEEN 15 AND 27 THEN '04-DESCANTADO'
                WHEN qtdeDiasUltTransacao > 27 THEN '05-ZUMBI'
                WHEN qtdeDiasUltTransacao <= 7 AND qtdeDiasPenultimaTransacao BETWEEN 15 AND 27 THEN '02-RECONQUISTADO'
                WHEN qtdeDiasUltTransacao <= 7 AND qtdeDiasPenultimaTransacao > 27 THEN '02-REBORN'
        END AS descLifeCycle

    FROM tb_idade AS t1

    LEFT JOIN tb_penultima_ativacao AS t2
    ON t1.IdCliente = t2.IdCliente
)

SELECT 
    date('{date}', '-1 day') AS dtRef, 
    *
FROM tb_life_cycle


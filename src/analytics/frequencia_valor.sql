WITH tb_freq_valor AS (
    select IdCliente,
        count(DISTINCT substr(DtCriacao,0,11)) AS qtdeFrequencia,
        sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos

    from transacoes 

    where DtCriacao < '2025-09-01' 
    and DtCriacao >= date('2025-09-01', '-28 day')
    GROUP BY 1
    ORDER BY qtdeFrequencia DESC
),

tb_cluster AS (

    SELECT *,
            CASE 
                WHEN qtdeFrequencia > 10 AND qtdePontosPos > 1500 THEN '12-HYPER'
                WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN '22-EFICIENTE'
                WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN '11-INDECISO'
                WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 750 THEN '21-ESFORCDO'
                WHEN qtdeFrequencia < 5 THEN '00-LURKER'
                WHEN qtdeFrequencia <= 10 THEN '01-PREGUICOSO'
                WHEN qtdeFrequencia > 10 THEN '20-POTENCIAL'
            END AS cluster

    FROM tb_freq_valor
)

SELECT *
FROM tb_cluster
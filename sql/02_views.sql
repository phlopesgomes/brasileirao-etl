-- =====================================================================
-- Views analíticas (camada de consumo para o Power BI)
-- Executar DEPOIS da carga dos dados.
-- =====================================================================
USE brasileirao;

-- ---------------------------------------------------------------------
-- vw_partida_clube: "despivota" a partida → 2 linhas (uma por clube).
-- É a base para classificação, aproveitamento, desempenho casa/fora etc.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_partida_clube AS
SELECT
    p.id_partida, p.ano_temporada, p.rodada, p.data_partida,
    p.id_clube_mandante  AS id_clube,
    p.id_clube_visitante AS id_adversario,
    'Mandante'           AS mando,
    p.gols_mandante      AS gols_pro,
    p.gols_visitante     AS gols_contra,
    CASE p.resultado WHEN 'M' THEN 'V' WHEN 'E' THEN 'E' ELSE 'D' END AS resultado,
    CASE p.resultado WHEN 'M' THEN 3   WHEN 'E' THEN 1   ELSE 0   END AS pontos
FROM fato_partida p
UNION ALL
SELECT
    p.id_partida, p.ano_temporada, p.rodada, p.data_partida,
    p.id_clube_visitante, p.id_clube_mandante, 'Visitante',
    p.gols_visitante, p.gols_mandante,
    CASE p.resultado WHEN 'V' THEN 'V' WHEN 'E' THEN 'E' ELSE 'D' END,
    CASE p.resultado WHEN 'V' THEN 3   WHEN 'E' THEN 1   ELSE 0   END
FROM fato_partida p;

-- ---------------------------------------------------------------------
-- vw_classificacao: tabela final de cada temporada (critérios CBF:
-- pontos > vitórias > saldo > gols pró).
-- Obs.: não considera punições do STJD (ex.: perda de pontos em 2013).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_classificacao AS
SELECT
    t.*,
    ROW_NUMBER() OVER (
        PARTITION BY t.ano_temporada
        ORDER BY t.pontos DESC, t.vitorias DESC, t.saldo_gols DESC, t.gols_pro DESC
    ) AS posicao,
    ROUND(100 * t.pontos / (3 * t.jogos), 1) AS aproveitamento_pct
FROM (
    SELECT
        pc.ano_temporada,
        pc.id_clube,
        c.nome_exibicao                         AS clube,
        COUNT(*)                                AS jogos,
        SUM(pc.pontos)                          AS pontos,
        SUM(pc.resultado = 'V')                 AS vitorias,
        SUM(pc.resultado = 'E')                 AS empates,
        SUM(pc.resultado = 'D')                 AS derrotas,
        SUM(pc.gols_pro)                        AS gols_pro,
        SUM(pc.gols_contra)                     AS gols_contra,
        SUM(pc.gols_pro) - SUM(pc.gols_contra)  AS saldo_gols
    FROM vw_partida_clube pc
    JOIN dim_clube c ON c.id_clube = pc.id_clube
    GROUP BY pc.ano_temporada, pc.id_clube, c.nome_exibicao
) t;

-- =====================================================================
-- Carga dos CSVs (camada gold) gerados pelo notebook — Opção B (Colab + Workbench)
-- Ordem: 01_schema.sql → ESTE ARQUIVO → 02_views.sql
--
-- Pré-requisitos (uma vez só):
--   1) No servidor:  SET GLOBAL local_infile = 1;
--   2) No Workbench: editar a conexão > Advanced > Others: OPT_LOCAL_INFILE=1
--   3) Troque o caminho abaixo pela pasta onde extraiu o .zip (use / mesmo no Windows)
-- =====================================================================
USE brasileirao;


LOAD DATA LOCAL INFILE 'C:/brasileirao_etl/output/dim_estado.csv'
INTO TABLE dim_estado CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/brasileirao_etl/output/dim_clube.csv'
INTO TABLE dim_clube CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/brasileirao_etl/output/dim_estadio.csv'
INTO TABLE dim_estadio CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/brasileirao_etl/output/dim_temporada.csv'
INTO TABLE dim_temporada CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/brasileirao_etl/output/fato_partida.csv'
INTO TABLE fato_partida CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- Conferência rápida
SELECT 'dim_estado' AS tabela, COUNT(*) AS linhas FROM dim_estado
UNION ALL SELECT 'dim_clube',     COUNT(*) FROM dim_clube
UNION ALL SELECT 'dim_estadio',   COUNT(*) FROM dim_estadio
UNION ALL SELECT 'dim_temporada', COUNT(*) FROM dim_temporada
UNION ALL SELECT 'fato_partida',  COUNT(*) FROM fato_partida;

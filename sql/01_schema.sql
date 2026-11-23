-- =====================================================================
-- Brasileirão Série A (2003–2026) — Modelo dimensional (esquema estrela)
-- Compatível com MySQL 8.0+ (testado também em MariaDB 10.11)
-- Execução: MySQL Workbench > File > Open SQL Script > Execute (⚡)
-- ATENÇÃO: recria as tabelas do zero (carga full refresh).
-- =====================================================================

CREATE DATABASE IF NOT EXISTS brasileirao
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE brasileirao;

DROP VIEW  IF EXISTS vw_classificacao;
DROP VIEW  IF EXISTS vw_partida_clube;
DROP TABLE IF EXISTS fato_partida;
DROP TABLE IF EXISTS dim_clube;
DROP TABLE IF EXISTS dim_estadio;
DROP TABLE IF EXISTS dim_temporada;
DROP TABLE IF EXISTS dim_estado;

-- ---------------------------------------------------------------------
-- Dimensões
-- ---------------------------------------------------------------------
CREATE TABLE dim_estado (
    sigla_uf   CHAR(2)      NOT NULL,
    nome_uf    VARCHAR(30)  NOT NULL,
    regiao     VARCHAR(12)  NOT NULL,
    PRIMARY KEY (sigla_uf)
) ENGINE=InnoDB;

CREATE TABLE dim_clube (
    id_clube       SMALLINT     NOT NULL,
    nome_clube     VARCHAR(40)  NOT NULL COMMENT 'Nome padronizado (chave natural, sem acento)',
    nome_exibicao  VARCHAR(40)  NOT NULL COMMENT 'Nome com acentuação para relatórios',
    sigla_uf       CHAR(2)      NOT NULL,
    PRIMARY KEY (id_clube),
    UNIQUE KEY uk_clube_nome (nome_clube),
    CONSTRAINT fk_clube_estado FOREIGN KEY (sigla_uf) REFERENCES dim_estado (sigla_uf)
) ENGINE=InnoDB;

CREATE TABLE dim_estadio (
    id_estadio    SMALLINT     NOT NULL,
    nome_estadio  VARCHAR(80)  NOT NULL,
    PRIMARY KEY (id_estadio),
    UNIQUE KEY uk_estadio_nome (nome_estadio)
) ENGINE=InnoDB;

CREATE TABLE dim_temporada (
    ano_temporada  SMALLINT     NOT NULL,
    qtd_clubes     TINYINT      NOT NULL,
    qtd_rodadas    TINYINT      NULL     COMMENT 'NULL quando a fonte não informa a rodada',
    qtd_partidas   SMALLINT     NOT NULL,
    data_inicio    DATE         NOT NULL,
    data_fim       DATE         NOT NULL,
    fonte          VARCHAR(30)  NOT NULL,
    em_andamento   TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (ano_temporada)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Fato (grão: 1 linha por partida)
-- ---------------------------------------------------------------------
CREATE TABLE fato_partida (
    id_partida          INT          NOT NULL,
    id_origem           INT          NULL     COMMENT 'ID da partida no dataset de origem',
    fonte               VARCHAR(30)  NOT NULL,
    ano_temporada       SMALLINT     NOT NULL,
    rodada              TINYINT      NULL,
    data_partida        DATE         NOT NULL,
    hora_partida        TIME         NULL,
    id_clube_mandante   SMALLINT     NOT NULL,
    id_clube_visitante  SMALLINT     NOT NULL,
    id_estadio          SMALLINT     NULL,
    gols_mandante       TINYINT      NOT NULL,
    gols_visitante      TINYINT      NOT NULL,
    resultado           CHAR(1)      NOT NULL COMMENT 'M = vitória mandante | E = empate | V = vitória visitante',
    formacao_mandante   VARCHAR(12)  NULL,
    formacao_visitante  VARCHAR(12)  NULL,
    tecnico_mandante    VARCHAR(60)  NULL,
    tecnico_visitante   VARCHAR(60)  NULL,
    portoes_fechados    TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (id_partida),
    UNIQUE KEY uk_partida (data_partida, id_clube_mandante, id_clube_visitante),
    KEY ix_partida_temporada (ano_temporada, rodada),
    KEY ix_partida_visitante (id_clube_visitante),
    KEY ix_partida_estadio (id_estadio),
    CONSTRAINT fk_partida_temporada FOREIGN KEY (ano_temporada)      REFERENCES dim_temporada (ano_temporada),
    CONSTRAINT fk_partida_mandante  FOREIGN KEY (id_clube_mandante)  REFERENCES dim_clube (id_clube),
    CONSTRAINT fk_partida_visitante FOREIGN KEY (id_clube_visitante) REFERENCES dim_clube (id_clube),
    CONSTRAINT fk_partida_estadio   FOREIGN KEY (id_estadio)         REFERENCES dim_estadio (id_estadio),
    CONSTRAINT ck_resultado CHECK (resultado IN ('M','E','V')),
    CONSTRAINT ck_clubes_distintos CHECK (id_clube_mandante <> id_clube_visitante),
    CONSTRAINT ck_gols CHECK (gols_mandante >= 0 AND gols_visitante >= 0)
) ENGINE=InnoDB;

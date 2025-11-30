# 🗺️ Pipeline de Dados Espaciais: Belém/PA

![R](https://img.shields.io/badge/Language-R-276DC3?style=for-the-badge&logo=r)
![Status](https://img.shields.io/badge/Status-Em_Desenvolvimento-yellow?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Este repositório contém um pipeline de Engenharia de Dados Espaciais desenvolvido em R para extração, tratamento e visualização de dados do **OpenStreetMap (OSM)**, focado na região metropolitana de Belém, Pará.

## 🎯 Objetivos do Projeto
- Automatizar o download de dados vetoriais (shapefiles/geopackages) de infraestrutura urbana.
- Realizar limpeza e transformação de coordenadas (CRS).
- Produzir visualizações cartográficas temáticas.

## 🛠️ Tecnologias Utilizadas
- **Linguagem:** R (versão 4.x)
- **Principais Bibliotecas:**
  - `sf`: Simple Features (manipulação geométrica)
  - `osmdata`: Interface com a API do OpenStreetMap
  - `ggplot2` / `tmap`: Visualização de dados
  - `tidyverse`: Manipulação e limpeza de dados

## 🚀 Como Executar
1. Clone este repositório:
```bash
git clone [https://github.com/gishorus/visualizacao-dados-espaciais.git](https://github.com/gishorus/visualizacao-dados-espaciais.git)
# 🗺️ OpenStreetMap Pipeline - Belém/PA

[![R](https://img.shields.io/badge/R-4.0%2B-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OSM](https://img.shields.io/badge/Data-OpenStreetMap-7ebc6f.svg)](https://www.openstreetmap.org/)
[![SIRGAS 2000](https://img.shields.io/badge/CRS-EPSG%3A31982-orange.svg)](https://epsg.io/31982)

> Pipeline automatizado em R para download, processamento e análise de dados geoespaciais do OpenStreetMap, com foco na região amazônica brasileira.

---

## 📍 Sobre o Projeto

Este repositório fornece um **framework completo em R** para trabalhar com dados do [OpenStreetMap](https://www.openstreetmap.org/), com aplicação prática para a cidade de **Belém, Pará**.

### 🎯 Características

- ✅ Funções reutilizáveis para qualquer cidade do mundo
- ✅ Sistema de coordenadas correto (SIRGAS 2000 / UTM 22S - EPSG:31982)
- ✅ Exportação automática para GeoPackage (compatível com QGIS)
- ✅ Visualizações geradas automaticamente
- ✅ Features específicas da região amazônica (portos, feiras, hidrografia)
- ✅ Código bem documentado e organizado

---

## 🚀 Quick Start

### Pré-requisitos
```r
# Instalar pacotes necessários
install.packages(c("osmdata", "sf", "dplyr"))
```

### Uso Básico
```r
# 1. Carregar funções
source("R/funcoes_osm.R")

# 2. Baixar vias principais de Belém
vias <- get_malha_viaria("Belém, Brazil", tipos_via = c("primary", "secondary"))

# 3. Baixar hospitais
hospitais <- get_poi("Belém, Brazil", "hospital")

# 4. Visualizar
plot(vias["highway"], main = "Vias Principais - Belém/PA")
```

---

## 📂 Estrutura do Projeto
```
visualizacao-dados-espaciais/
│
├── R/
│   ├── funcoes_osm.R         # Funções genéricas reutilizáveis
│   └── OSM_Belem_no_R.R      # Script completo para Belém
│
├── dados/                    # GeoPackages exportados (gitignored)
│
├── mapas/                    # Visualizações PNG (gitignored)
│
├── Docs/                     # Documentação adicional
│
├── Exemplos/                 # Scripts de exemplo
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🔧 Funcionalidades

### 1️⃣ Download de Dados OSM
```r
# Malha viária completa
vias <- get_malha_viaria("Belém, Brazil")

# Apenas vias principais
vias_principais <- get_malha_viaria(
  "Belém, Brazil",
  tipos_via = c("motorway", "trunk", "primary")
)

# Pontos de interesse
hospitais <- get_poi("Belém, Brazil", "hospital")
escolas <- get_poi("Belém, Brazil", "school")
restaurantes <- get_poi("Belém, Brazil", "restaurant")

# Áreas verdes
parques <- get_areas_verdes("Belém, Brazil")
```

### 2️⃣ Features Específicas da Amazônia
```r
# Portos e atracadouros (importante em Belém)
portos <- get_osm_feature("Belém, Brazil", key = "harbour")

# Feiras e mercados municipais
feiras <- get_osm_feature("Belém, Brazil", key = "amenity", value = "marketplace")

# Hidrografia (rios, igarapés)
rios <- get_osm_feature("Belém, Brazil", key = "waterway")
```

### 3️⃣ Exportação para QGIS
```r
# Exportar para GeoPackage
exportar_camada(vias, "dados/vias_belem.gpkg", "vias")
```

### 4️⃣ Análises Espaciais
```r
# Calcular área de parques
parques$area_km2 <- as.numeric(st_area(parques)) / 1e6

# Resumo estatístico
resumir_osm(parques, "Parques de Belém")
```

---

## 🗺️ Sistema de Referência

### EPSG:31982 - SIRGAS 2000 / UTM zone 22S

- **Adequado para**: Belém/PA e região Norte
- **Zona UTM**: 22 Sul
- **Datum**: SIRGAS 2000
- **Unidade**: metros
```r
# Todas as funções usam EPSG:31982 por padrão
# Para mudar o CRS:
vias <- get_malha_viaria("Belém, Brazil", crs = 4326)  # WGS84
```

---

## 📊 Dados Disponíveis

### 🏙️ Infraestrutura Urbana
- 🚗 Malha viária (todas as categorias OSM)
- 🚌 Pontos de ônibus
- 🏥 Hospitais e clínicas
- 🏫 Escolas
- 💊 Farmácias
- 🏢 Edifícios

### 🛒 Comércio e Serviços
- 🍽️ Restaurantes
- 🛒 Mercados e feiras
- ⚓ Portos e atracadouros

### 🌿 Meio Ambiente
- 🌳 Parques e praças
- 💧 Rios e igarapés
- 🌊 Áreas de mangue (se disponível no OSM)

---

## 📖 Documentação das Funções

### `get_malha_viaria(cidade, crs, tipos_via)`
Baixa a malha viária completa ou filtrada.

**Parâmetros:**
- `cidade`: Nome da cidade ou bounding box
- `crs`: Código EPSG (padrão: 31982)
- `tipos_via`: Vetor com tipos de via para filtrar (opcional)

**Retorna:** Objeto `sf` com geometrias de linhas

---

### `get_poi(cidade, tipo, crs)`
Baixa pontos de interesse.

**Parâmetros:**
- `cidade`: Nome da cidade
- `tipo`: Tipo de amenity ("hospital", "school", etc.)
- `crs`: Código EPSG (padrão: 31982)

**Retorna:** Objeto `sf` com geometrias de pontos

---

### `get_areas_verdes(cidade, crs)`
Baixa parques e áreas verdes.

---

### `get_osm_feature(cidade, key, value, crs, tipo_geom)`
Função genérica para qualquer feature do OSM.

---

### `resumir_osm(objeto_sf, nome)`
Gera resumo estatístico de um objeto espacial.

---

### `exportar_camada(objeto_sf, arquivo, camada_nome)`
Exporta dados para GeoPackage com tratamento de erros.

---

## 🤝 Como Contribuir

Contribuições são muito bem-vindas! 

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

### 💡 Ideias para Contribuição

- Adicionar suporte para mais cidades brasileiras
- Criar análises espaciais avançadas
- Desenvolver dashboard interativo com Shiny
- Melhorar visualizações
- Adicionar testes automatizados

---

## 🌎 Roadmap

- [x] Funções básicas de download OSM
- [x] Exportação para GeoPackage
- [x] Visualizações automáticas
- [x] Documentação completa
- [ ] Suporte para mais cidades (Brasília, Manaus, Fortaleza)
- [ ] Análises espaciais avançadas
- [ ] Dashboard interativo com Shiny
- [ ] Pacote R oficial no CRAN
- [ ] Integração com outras fontes (IBGE, etc)

---

## 📄 Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

### Dados OpenStreetMap

Os dados do OpenStreetMap são © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright) e estão disponíveis sob a [Open Database License (ODbL)](https://opendatacommons.org/licenses/odbl/).

---

## 🙏 Agradecimentos

- **OpenStreetMap Contributors** - pelos dados abertos
- **Pacote osmdata** ([Padgham et al.](https://github.com/ropensci/osmdata))
- **Pacote sf** ([Pebesma](https://github.com/r-spatial/sf))
- **Comunidade R-Spatial** - pelo suporte e ferramentas

---

## 📞 Contato

- **GitHub**: [@gishorus](https://github.com/gishorus)
- **Issues**: [Reportar problemas](https://github.com/gishorus/visualizacao-dados-espaciais/issues)

---

## ⭐ Star o Projeto

Se este projeto foi útil para você, considere dar uma ⭐ estrela!

---

<p align="center">
  <sub>Feito com ❤️ e R para a comunidade geoespacial brasileira</sub>
</p>

<p align="center">
  <sub>Dados de OpenStreetMap | SIRGAS 2000 | Região Amazônica</sub>
</p>

# 🗺️ OpenStreetMap - Belém/PA

Pipeline automatizado em R para download e análise de dados do OpenStreetMap.

## 📍 Área de Estudo
- **Cidade:** Belém, Pará, Brasil
- **CRS:** SIRGAS 2000 / UTM 22S (EPSG:31982)

## 🚀 Como Usar
```r
# 1. Carregar funções
source("R/funcoes_osm.R")

# 2. Executar exemplo de Belém
source("R/exemplo_belem.R")
```

## 📦 Pacotes Necessários
```r
install.packages(c("osmdata", "sf", "dplyr"))
```

## 📂 Estrutura
```
├── R/                  # Scripts R
├── dados/              # GeoPackages gerados
├── mapas/              # Visualizações PNG
├── Docs/               # Documentação
└── Exemplos/           # Exemplos de uso
```

## 🔧 Funcionalidades

- ✅ Download de malha viária
- ✅ Pontos de interesse (hospitais, escolas, etc)
- ✅ Áreas verdes (parques)
- ✅ Hidrografia (rios, igarapés)
- ✅ Exportação para GeoPackage (QGIS)

## 📄 Licença

MIT License

## 🙏 Créditos

Dados © OpenStreetMap contributors
```
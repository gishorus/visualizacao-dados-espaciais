<p align="center">
  <img src="https://www.r-project.org/logo/Rlogo.png" width="120" alt="R Logo"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Openstreetmap_logo.svg/256px-Openstreetmap_logo.svg.png" width="120" alt="OpenStreetMap Logo"/>
</p>

<h1 align="center">Pipeline de Dados Espaciais: Belém/PA</h1>

<p align="center">
  <strong>Pipeline automatizado em R para dados OpenStreetMap</strong>
</p>

<p align="center">
  <a href="https://www.r-project.org/">
    <img src="https://img.shields.io/badge/R-4.0%2B-276DC3?style=for-the-badge&logo=r&logoColor=white" alt="R 4.0+"/>
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge" alt="MIT License"/>
  </a>
  <a href="https://www.openstreetmap.org/">
    <img src="https://img.shields.io/badge/Data-OpenStreetMap-7ebc6f.svg?style=for-the-badge&logo=openstreetmap&logoColor=white" alt="OpenStreetMap"/>
  </a>
  <a href="https://epsg.io/31982">
    <img src="https://img.shields.io/badge/CRS-EPSG%3A31982-orange.svg?style=for-the-badge" alt="SIRGAS 2000"/>
  </a>
</p>

<p align="center">
  <a href="#-sobre-o-projeto">Sobre</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-funcionalidades">Funcionalidades</a> •
  <a href="#-documentação">Documentação</a> •
  <a href="#-como-contribuir">Contribuir</a> •
  <a href="#-licença">Licença</a>
</p>

---

## Sobre o Projeto

Framework completo em **R** para trabalhar com dados do [OpenStreetMap](https://www.openstreetmap.org/), com aplicação prática para **Belém, Pará** e outras cidades da Amazônia brasileira.

### Destaques

<table>
<tr>
<td width="50%">

** Para Pesquisadores**
- Funções reutilizáveis
- Código bem documentado
- Exemplos práticos
- Sistema de coordenadas correto

</td>
<td width="50%">

** Para Desenvolvedores**
- Código modular e limpo
- Exportação para QGIS
- Análises automatizadas
- Open source (MIT)

</td>
</tr>
</table>

###  Características Principais
```
✅ Funções reutilizáveis para qualquer cidade
✅ SIRGAS 2000 / UTM 22S (EPSG:31982)
✅ Exportação para GeoPackage/QGIS
✅ Visualizações automáticas
✅ Features amazônicas (portos, feiras, rios)
✅ Documentação completa
```

---

##  Quick Start

### Instalação
```r
# 1. Instalar pacotes necessários
install.packages(c("osmdata", "sf", "dplyr"))

# 2. Carregar funções
source("R/funcoes_osm.R")
```

### Exemplo Básico
```r
# Baixar vias principais de Belém
vias <- get_malha_viaria(
  "Belém, Brazil", 
  tipos_via = c("primary", "secondary")
)

# Baixar hospitais
hospitais <- get_poi("Belém, Brazil", "hospital")

# Visualizar
plot(vias["highway"], main = "Vias Principais - Belém/PA")
plot(st_geometry(hospitais), add = TRUE, col = "red", pch = 16)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/gishorus/visualizacao-dados-espaciais/main/mapas/exemplo.png" width="600" alt="Exemplo de Mapa"/>
  <br>
  <em>Exemplo de visualização gerada pelo pipeline</em>
</p>

---

##  Estrutura do Projeto
```
 visualizacao-dados-espaciais
├── 📂 R/
│   ├── 📄 funcoes_osm.R          # 🔧 Funções reutilizáveis
│   └── 📄 OSM_Belem_no_R.R       # 📝 Script completo
├── 📂 dados/                     # 💾 GeoPackages (gitignored)
├── 📂 mapas/                     # 🗺️  Visualizações (gitignored)
├── 📂 Docs/                      # 📚 Documentação
├── 📂 Exemplos/                  # 💡 Scripts de exemplo
├── 📄 README.md                  # 📖 Este arquivo
├── 📄 LICENSE                    # ⚖️  MIT License
└── 📄 .gitignore                 # 🚫 Arquivos ignorados
```

---

##  Funcionalidades

<details>
<summary><b>🗺️ Download de Dados OSM</b></summary>
```r
# Malha viária
vias <- get_malha_viaria("Belém, Brazil")
vias_principais <- get_malha_viaria("Belém, Brazil", 
                                    tipos_via = c("motorway", "primary"))

# Pontos de interesse
hospitais <- get_poi("Belém, Brazil", "hospital")
escolas <- get_poi("Belém, Brazil", "school")
restaurantes <- get_poi("Belém, Brazil", "restaurant")

# Áreas verdes
parques <- get_areas_verdes("Belém, Brazil")
```
</details>

<details>
<summary><b> Features Amazônicas</b></summary>
```r
# Portos e atracadouros
portos <- get_osm_feature("Belém, Brazil", key = "harbour")

# Feiras municipais
feiras <- get_osm_feature("Belém, Brazil", 
                          key = "amenity", 
                          value = "marketplace")

# Hidrografia (rios, igarapés)
rios <- get_osm_feature("Belém, Brazil", key = "waterway")

# Áreas de mangue
mangues <- get_osm_feature("Belém, Brazil", 
                           key = "natural", 
                           value = "wetland")
```
</details>

<details>
<summary><b> Exportação e Análise</b></summary>
```r
# Exportar para GeoPackage (QGIS)
exportar_camada(vias, "dados/vias_belem.gpkg", "vias")

# Calcular áreas
parques$area_km2 <- as.numeric(st_area(parques)) / 1e6

# Resumo estatístico
resumir_osm(parques, "Parques de Belém")
```
</details>

---

##  Dados Disponíveis

<table>
<tr>
<td width="33%" align="center">

###  Infraestrutura
🚗 Malha viária<br>
🚌 Pontos de ônibus<br>
🏥 Hospitais<br>
🏫 Escolas<br>
💊 Farmácias<br>
🏢 Edifícios

</td>
<td width="33%" align="center">

###  Comércio
🍽️ Restaurantes<br>
🛒 Mercados<br>
🏪 Feiras<br>
⚓ Portos<br>
🏬 Shopping centers

</td>
<td width="33%" align="center">

###  Meio Ambiente
🌳 Parques<br>
💧 Rios<br>
🌊 Igarapés<br>
🏞️ Áreas verdes<br>
🦜 Mangues

</td>
</tr>
</table>

---

## 🗺️ Sistema de Referência

<p align="center">
  <img src="https://epsg.io/31982.png" width="400" alt="UTM Zone 22S"/>
</p>

### EPSG:31982 - SIRGAS 2000 / UTM zone 22S

| Propriedade | Valor |
|-------------|-------|
| **Datum** | SIRGAS 2000 |
| **Zona UTM** | 22 Sul |
| **Região** | Norte do Brasil (Belém/PA) |
| **Unidade** | metros |
| **EPSG** | 31982 |
```r
# Todas as funções usam EPSG:31982 por padrão
vias <- get_malha_viaria("Belém, Brazil")  # → UTM 22S

# Para usar outro CRS:
vias_wgs84 <- get_malha_viaria("Belém, Brazil", crs = 4326)
```

---

## 📖 Documentação

### Funções Principais

<table>
<tr>
<td width="50%">

**`get_malha_viaria()`**
```r
get_malha_viaria(
  cidade, 
  crs = 31982, 
  tipos_via = NULL
)
```
Baixa malha viária completa ou filtrada.

</td>
<td width="50%">

**`get_poi()`**
```r
get_poi(
  cidade, 
  tipo, 
  crs = 31982
)
```
Baixa pontos de interesse (POI).

</td>
</tr>
<tr>
<td>

**`get_areas_verdes()`**
```r
get_areas_verdes(
  cidade, 
  crs = 31982
)
```
Baixa parques e áreas verdes.

</td>
<td>

**`get_osm_feature()`**
```r
get_osm_feature(
  cidade, 
  key, 
  value = NULL,
  crs = 31982,
  tipo_geom = "all"
)
```
Função genérica para qualquer feature OSM.

</td>
</tr>
</table>

### Funções Auxiliares

| Função | Descrição |
|--------|-----------|
| `resumir_osm()` | Gera resumo estatístico |
| `exportar_camada()` | Exporta para GeoPackage |

---

##  Como Contribuir

Agradecemos sua contribuição!

###  Formas de Contribuir

<table>
<tr>
<td width="50%">

**Para Usuários**
- ⭐ Dar uma estrela no projeto
- 🐛 Reportar bugs
- 💡 Sugerir funcionalidades
- 📝 Melhorar documentação

</td>
<td width="50%">

**Para Desenvolvedores**
- 🔧 Corrigir bugs
- ✨ Adicionar features
- 🌎 Adicionar cidades
- 🧪 Escrever testes

</td>
</tr>
</table>

###  Processo de Contribuição
```bash
# 1. Fork o projeto
# 2. Clone seu fork
git clone https://github.com/SEU-USUARIO/visualizacao-dados-espaciais.git

# 3. Crie uma branch
git checkout -b feature/MinhaContribuicao

# 4. Faça suas alterações e commit
git commit -m "feat: adiciona nova funcionalidade"

# 5. Push para seu fork
git push origin feature/MinhaContribuicao

# 6. Abra um Pull Request
```

###  Ideias para Contribuição

- [ ] Adicionar suporte para Brasília, Manaus, Fortaleza
- [ ] Criar análises de acessibilidade espacial
- [ ] Desenvolver dashboard Shiny interativo
- [ ] Implementar análises de buffer e proximidade
- [ ] Adicionar suporte para dados temporais
- [ ] Criar tutoriais em vídeo
- [ ] Traduzir documentação para inglês

---

## 🌎 Roadmap

###  Versão 1.0 (Atual)
- [x] Funções básicas de download OSM
- [x] Exportação para GeoPackage
- [x] Visualizações automáticas
- [x] Documentação completa
- [x] Suporte para Belém/PA

###  Versão 1.1 (Em Breve)
- [ ] Suporte para 5+ cidades brasileiras
- [ ] Análises espaciais avançadas
- [ ] Testes automatizados
- [ ] Vinhetas (tutoriais)

###  Futuro
- [ ] Dashboard Shiny interativo
- [ ] Pacote R oficial no CRAN
- [ ] API REST
- [ ] Integração com IBGE

---

##  Licença

<p align="center">
  <img src="https://opensource.org/files/osi_symbol.png" width="100" alt="Open Source"/>
</p>

Este projeto está sob a licença **MIT** - veja o arquivo [LICENSE](LICENSE) para detalhes.

### Dados OpenStreetMap

Os dados do OpenStreetMap são © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright) e estão disponíveis sob a [Open Database License (ODbL)](https://opendatacommons.org/licenses/odbl/).

---

##  Agradecimentos

<table>
<tr>
<td align="center" width="25%">
  <img src="https://www.openstreetmap.org/assets/osm_logo-d4979005d8a03c261191d2e1d6d01a89b1e0f7e6c2a4c8c6e6e2e6e6e6e6e6e6.svg" width="60"/><br>
  <b>OpenStreetMap</b><br>
  <sub>Dados abertos</sub>
</td>
<td align="center" width="25%">
  <img src="https://www.r-project.org/logo/Rlogo.png" width="60"/><br>
  <b>R Project</b><br>
  <sub>Linguagem</sub>
</td>
<td align="center" width="25%">
  <img src="https://user-images.githubusercontent.com/520851/34887433-ce1d130e-f7c6-11e7-83fc-d60ad4fae6bd.gif" width="60"/><br>
  <b>osmdata</b><br>
  <sub>Padgham et al.</sub>
</td>
<td align="center" width="25%">
  <img src="https://keen-swartz-3146c4.netlify.app/images/hex/sf.png" width="60"/><br>
  <b>sf package</b><br>
  <sub>Pebesma</sub>
</td>
</tr>
</table>

---

##  Contato

<p align="center">
  <a href="https://github.com/gishorus">
    <img src="https://img.shields.io/badge/GitHub-gishorus-181717?style=for-the-badge&logo=github" alt="GitHub"/>
  </a>
  <a href="https://github.com/gishorus/visualizacao-dados-espaciais/issues">
    <img src="https://img.shields.io/badge/Issues-Reportar-red?style=for-the-badge&logo=github" alt="Issues"/>
  </a>
</p>

---

## ⭐ Star o Projeto

<p align="center">
  <b>Se este projeto foi útil para você, considere dar uma ⭐ estrela!</b><br>
  Isso ajuda outros pesquisadores a encontrarem este trabalho.
</p>

<p align="center">
  <a href="https://github.com/gishorus/visualizacao-dados-espaciais">
    <img src="https://img.shields.io/github/stars/gishorus/visualizacao-dados-espaciais?style=social" alt="GitHub stars"/>
  </a>
  <a href="https://github.com/gishorus/visualizacao-dados-espaciais/fork">
    <img src="https://img.shields.io/github/forks/gishorus/visualizacao-dados-espaciais?style=social" alt="GitHub forks"/>
  </a>
</p>

---

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:83a4d4,100:b6fbff&height=120&section=footer" width="100%"/>
</p>

<p align="center">
  <sub>Feito com R para a comunidade geoespacial </sub>
</p>

<p align="center">
  <sub>OpenStreetMap | SIRGAS 2000 | Amazônia</sub>
</p>

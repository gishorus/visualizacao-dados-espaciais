############################################################
# TRABALHANDO COM OPENSTREETMAP NO R
# Script para BELÉM / PA - SIRGAS 2000 / UTM 22S (EPSG: 31982)
# Versão otimizada com features específicas da região amazônica
############################################################


# =========================================================
# 0. CONFIGURAÇÃO GERAL
# =========================================================

# Limpar ambiente
rm(list = ls())

# Criar estrutura de pastas
if (!dir.exists("dados")) dir.create("dados")
if (!dir.exists("mapas")) dir.create("mapas")

# =========================================================
# 1. CARREGAR PACOTES
# =========================================================

# Instalar se necessário:
install.packages(c("osmdata", "sf", "dplyr", "tmap"))

suppressPackageStartupMessages({
  library(osmdata)
  library(sf)
  library(dplyr)
  # library(tmap)  # Opcional: mapas temáticos bonitos
})

cat("Pacotes carregados com sucesso!\n")

# =========================================================
# 2. CONFIGURAÇÕES ESPECÍFICAS PARA BELÉM
# =========================================================

# Definir cidade e CRS
CIDADE <- "Belém, Brazil"
CRS_UTM22S <- 31982  # SIRGAS 2000 / UTM zone 22S

cat(paste("\n🗺️  Configuração:\n"))
cat(paste("   • Cidade:", CIDADE, "\n"))
cat(paste("   • CRS:", CRS_UTM22S, "(UTM 22S)\n"))

# =========================================================
# 3. FUNÇÕES GENÉRICAS PARA OSM
# =========================================================

# ---------------------------------------------------------
# 3.1 Função: Malha viária (linhas)
# ---------------------------------------------------------

get_malha_viaria <- function(cidade, crs = CRS_UTM22S, tipos_via = NULL) {
  message(paste(" Baixando malha viária de:", cidade))
  
  consulta <- opq(bbox = cidade) |>
    add_osm_feature(key = "highway")
  
  dados <- osmdata_sf(consulta)
  lin <- dados$osm_lines
  
  if (is.null(lin) || nrow(lin) == 0) {
    warning("  Nenhuma via encontrada")
    return(NULL)
  }
  
  message(paste("   ✓", nrow(lin), "vias encontradas"))
  
  if (!is.null(tipos_via)) {
    lin <- lin[lin$highway %in% tipos_via, ]
    message(paste("   ✓ Filtrado:", nrow(lin), "vias"))
  }
  
  if (!is.null(crs)) {
    lin <- st_transform(lin, crs)
  }
  
  return(lin)
}
# ---------------------------------------------------------
# 3.2 Função: Edifícios (polígonos)
# ---------------------------------------------------------
get_edificios <- function(cidade, crs = CRS_UTM22S, tipo_edificio = NULL) {
  message(paste(" Baixando edifícios de:", cidade))
  
  consulta <- opq(bbox = cidade) |>
    add_osm_feature(key = "building")
  
  dados <- osmdata_sf(consulta)
  poligonos <- dados$osm_polygons
  
  if (is.null(poligonos) || nrow(poligonos) == 0) {
    warning("  Nenhum edifício encontrado")
    return(NULL)
  }
  
  message(paste("   ✓", nrow(poligonos), "edifícios encontrados"))
  
  if (!is.null(tipo_edificio)) {
    poligonos <- poligonos[poligonos$building %in% tipo_edificio, ]
    message(paste("   ✓ Filtrado:", nrow(poligonos), "edifícios"))
  }
  
  if (!is.null(crs)) {
    poligonos <- st_transform(poligonos, crs)
  }
  
  return(poligonos)
}

# ---------------------------------------------------------
# 3.3 Função: Pontos de interesse (POI)
# ---------------------------------------------------------
get_poi <- function(cidade, tipo, crs = CRS_UTM22S) {
  message(paste(" Baixando POI:", tipo))
  
  consulta <- opq(bbox = cidade) |>
    add_osm_feature(key = "amenity", value = tipo)
  
  dados <- osmdata_sf(consulta)
  pontos <- dados$osm_points
  
  if (is.null(pontos) || nrow(pontos) == 0) {
    warning(paste("  Nenhum", tipo, "encontrado"))
    return(NULL)
  }
  
  message(paste("   ✓", nrow(pontos), "pontos"))
  
  if (!is.null(crs)) {
    pontos <- st_transform(pontos, crs)
  }
  
  return(pontos)
}


# ---------------------------------------------------------
# 3.4 Função: Áreas verdes
# ---------------------------------------------------------
get_areas_verdes <- function(cidade, crs = CRS_UTM22S) {
  message(paste(" Baixando áreas verdes de:", cidade))
  
  consulta <- opq(bbox = cidade) |>
    add_osm_feature(key = "leisure", value = "park")
  
  dados <- osmdata_sf(consulta)
  poligonos <- dados$osm_polygons
  
  if (is.null(poligonos) || nrow(poligonos) == 0) {
    warning("️  Nenhum parque encontrado")
    return(NULL)
  }
  
  message(paste("   ✓", nrow(poligonos), "parques"))
  
  if (!is.null(crs)) {
    poligonos <- st_transform(poligonos, crs)
  }
  
  return(poligonos)
}


# ---------------------------------------------------------
# 3.5 Função genérica OSM (flexível)
# ---------------------------------------------------------
get_osm_feature <- function(cidade, key, value = NULL, 
                            crs = CRS_UTM22S, tipo_geom = "all") {
  msg <- paste(" Baixando:", key)
  if (!is.null(value)) msg <- paste(msg, "=", value)
  message(msg)
  
  consulta <- opq(bbox = cidade)
  
  if (is.null(value)) {
    consulta <- add_osm_feature(consulta, key = key)
  } else {
    consulta <- add_osm_feature(consulta, key = key, value = value)
  }
  
  dados <- osmdata_sf(consulta)
  
  resultado <- switch(tipo_geom,
                      "points"   = dados$osm_points,
                      "lines"    = dados$osm_lines,
                      "polygons" = dados$osm_polygons,
                      "all"      = list(
                        points   = dados$osm_points,
                        lines    = dados$osm_lines,
                        polygons = dados$osm_polygons
                      )
  )
  
  if (!is.list(resultado) && !is.null(crs) && !is.null(resultado)) {
    resultado <- st_transform(resultado, crs)
  }
  
  return(resultado)
}


# ---------------------------------------------------------
# 3.6 Resumo estatístico
# ---------------------------------------------------------
resumir_osm <- function(objeto_sf, nome = "Camada") {
  if (is.null(objeto_sf)) {
    cat(paste(" ", nome, ": sem dados\n"))
    return(invisible(NULL))
  }
  
  cat(paste("\n ", nome, "\n"))
  cat(paste("   • Feições:", nrow(objeto_sf), "\n"))
  cat(paste("   • CRS:", st_crs(objeto_sf)$input, "\n"))
  cat(paste("   • Geometria:", 
            paste(unique(st_geometry_type(objeto_sf)), collapse = ", "), "\n"))
  
  bbox <- st_bbox(objeto_sf)
  cat("   • Extensão:\n")
  cat(paste("      X:", round(bbox$xmin, 2), "→", round(bbox$xmax, 2), "\n"))
  cat(paste("      Y:", round(bbox$ymin, 2), "→", round(bbox$ymax, 2), "\n"))
  
  return(invisible(objeto_sf))
}


# ---------------------------------------------------------
# 3.7 Função de exportação segura
# ---------------------------------------------------------
exportar_camada <- function(objeto_sf, arquivo, camada_nome) {
  if (is.null(objeto_sf) || nrow(objeto_sf) == 0) {
    message(paste("  Pulando:", camada_nome, "(sem dados)"))
    return(invisible(FALSE))
  }
  
  tryCatch({
    st_write(
      objeto_sf, arquivo, layer = camada_nome,
      delete_layer = TRUE, quiet = TRUE
    )
    message(paste(" ", camada_nome, "→", basename(arquivo)))
    return(invisible(TRUE))
  }, error = function(e) {
    warning(paste(" Erro:", camada_nome, "-", e$message))
    return(invisible(FALSE))
  })
}



# =========================================================
# 4. BAIXAR DADOS DE BELÉM
# =========================================================

cat("\n" , rep("=", 60), "\n", sep = "")
cat(" INICIANDO DOWNLOAD DOS DADOS DE BELÉM\n")
cat(rep("=", 60), "\n\n", sep = "")


# ---------------------------------------------------------
# 4.1 Malha viária
# ---------------------------------------------------------
lin_belem <- get_malha_viaria(CIDADE)
resumir_osm(lin_belem, "Malha viária completa")

vias_principais <- get_malha_viaria(
  CIDADE,
  tipos_via = c("motorway", "trunk", "primary", "secondary", "tertiary")
)
resumir_osm(vias_principais, "Vias principais")


# ---------------------------------------------------------
# 4.2 Distribuição de tipos de via
# ---------------------------------------------------------
if (!is.null(lin_belem)) {
  cat("\n TOP 10 TIPOS DE VIA:\n")
  tipos <- sort(table(lin_belem$highway), decreasing = TRUE)[1:10]
  print(tipos)
}


# ---------------------------------------------------------
# 4.3 POI (Pontos de Interesse)
# ---------------------------------------------------------
hospitais    <- get_poi(CIDADE, "hospital")
escolas      <- get_poi(CIDADE, "school")
restaurantes <- get_poi(CIDADE, "restaurant")
farmacias    <- get_poi(CIDADE, "pharmacy")
mercados     <- get_poi(CIDADE, "marketplace")

resumir_osm(hospitais, "Hospitais")
resumir_osm(escolas, "Escolas")
resumir_osm(restaurantes, "Restaurantes")
resumir_osm(farmacias, "Farmácias")
resumir_osm(mercados, "Mercados")


# ---------------------------------------------------------
# 4.4 Áreas verdes
# ---------------------------------------------------------
parques <- get_areas_verdes(CIDADE)
resumir_osm(parques, "Parques")

if (!is.null(parques)) {
  parques$area_m2  <- as.numeric(st_area(parques))
  parques$area_km2 <- parques$area_m2 / 1e6
  
  cat("\n  ESTATÍSTICAS DE ÁREA (km²):\n")
  print(summary(parques$area_km2))
  
  # Maiores parques
  top_parques <- parques |>
    arrange(desc(area_km2)) |>
    select(name, area_km2) |>
    head(5) |>
    st_drop_geometry()
  
  cat("\n TOP 5 MAIORES PARQUES:\n")
  print(top_parques)
}


# ---------------------------------------------------------
# 4.5 Features específicas da região amazônica
# ---------------------------------------------------------
cat("\n  FEATURES ESPECÍFICAS DA REGIÃO AMAZÔNICA:\n")

# Portos e atracadouros (importante em Belém)
portos <- get_osm_feature(CIDADE, key = "harbour", tipo_geom = "points")
resumir_osm(portos, "Portos")

# Mercados municipais e feiras
feiras <- get_osm_feature(CIDADE, key = "amenity", value = "marketplace", 
                          tipo_geom = "polygons")
resumir_osm(feiras, "Feiras")

# Hidrografia (rios, igarapés)
rios <- get_osm_feature(CIDADE, key = "waterway", tipo_geom = "lines")
resumir_osm(rios, "Rios e igarapés")

# Áreas de mangue (se mapeadas)
mangues <- get_osm_feature(CIDADE, key = "natural", value = "wetland", 
                           tipo_geom = "polygons")
resumir_osm(mangues, "Áreas de mangue")


# ---------------------------------------------------------
# 4.6 Transporte público
# ---------------------------------------------------------
pontos_onibus <- get_osm_feature(
  CIDADE, key = "highway", value = "bus_stop", tipo_geom = "points"
)
resumir_osm(pontos_onibus, "Pontos de ônibus")



# =========================================================
# 5. VISUALIZAÇÕES
# =========================================================

cat("\n", rep("=", 60), "\n", sep = "")
cat("🗺️  GERANDO VISUALIZAÇÕES\n")
cat(rep("=", 60), "\n\n", sep = "")


# ---------------------------------------------------------
# 5.1 Mapa geral da malha viária
# ---------------------------------------------------------
if (!is.null(lin_belem)) {
  png("mapas/01_malha_viaria_belem.png", width = 1200, height = 900)
  plot(lin_belem["highway"], 
       main = "Malha Viária - Belém/PA",
       key.pos = 4, key.width = lcm(15))
  dev.off()
  cat("  Salvo: mapas/01_malha_viaria_belem.png\n")
}


# ---------------------------------------------------------
# 5.2 Vias principais
# ---------------------------------------------------------
if (!is.null(vias_principais)) {
  png("mapas/02_vias_principais_belem.png", width = 1200, height = 900)
  plot(vias_principais["highway"],
       main = "Vias Principais - Belém/PA",
       key.pos = 4, key.width = lcm(12))
  dev.off()
  cat("  Salvo: mapas/02_vias_principais_belem.png\n")
}


# ---------------------------------------------------------
# 5.3 Mapa de POI
# ---------------------------------------------------------
if (!is.null(vias_principais)) {
  png("mapas/03_poi_belem.png", width = 1200, height = 900)
  
  plot(st_geometry(vias_principais), 
       main = "Pontos de Interesse - Belém/PA",
       col = "gray85", lwd = 0.3)
  
  if (!is.null(hospitais)) {
    plot(st_geometry(hospitais), add = TRUE, 
         col = "red", pch = 16, cex = 1.5)
  }
  if (!is.null(escolas)) {
    plot(st_geometry(escolas), add = TRUE, 
         col = "blue", pch = 17, cex = 1.2)
  }
  if (!is.null(restaurantes)) {
    plot(st_geometry(restaurantes), add = TRUE, 
         col = "orange", pch = 15, cex = 0.8)
  }
  if (!is.null(farmacias)) {
    plot(st_geometry(farmacias), add = TRUE, 
         col = "green", pch = 18, cex = 1)
  }
  
  legend("bottomright", 
         legend = c("Hospitais", "Escolas", "Restaurantes", "Farmácias"),
         col = c("red", "blue", "orange", "green"),
         pch = c(16, 17, 15, 18),
         bg = "white", cex = 0.9)
  
  dev.off()
  cat("  Salvo: mapas/03_poi_belem.png\n")
}


# ---------------------------------------------------------
# 5.4 Mapa de parques
# ---------------------------------------------------------
if (!is.null(parques)) {
  png("mapas/04_parques_belem.png", width = 1200, height = 900)
  
  plot(st_geometry(parques),
       main = "Áreas Verdes (Parques) - Belém/PA",
       col = "forestgreen", border = "darkgreen", lwd = 0.5)
  
  dev.off()
  cat("  alvo: mapas/04_parques_belem.png\n")
}


# ---------------------------------------------------------
# 5.5 Hidrografia
# ---------------------------------------------------------
if (!is.null(rios)) {
  png("mapas/05_hidrografia_belem.png", width = 1200, height = 900)
  
  plot(st_geometry(rios),
       main = "Hidrografia - Belém/PA",
       col = "dodgerblue", lwd = 1.5)
  
  dev.off()
  cat("  Salvo: mapas/05_hidrografia_belem.png\n")
}



# =========================================================
# 6. EXPORTAR PARA QGIS
# =========================================================

cat("\n", rep("=", 60), "\n", sep = "")
cat("  EXPORTANDO DADOS PARA QGIS\n")
cat(rep("=", 60), "\n\n", sep = "")


# ---------------------------------------------------------
# 6.1 Arquivos individuais por categoria
# ---------------------------------------------------------
exportar_camada(vias_principais, "dados/01_viario_belem.gpkg", "vias_principais")
exportar_camada(hospitais,       "dados/02_saude_belem.gpkg", "hospitais")
exportar_camada(farmacias,       "dados/02_saude_belem.gpkg", "farmacias")
exportar_camada(escolas,         "dados/03_educacao_belem.gpkg", "escolas")
exportar_camada(restaurantes,    "dados/04_comercio_belem.gpkg", "restaurantes")
exportar_camada(mercados,        "dados/04_comercio_belem.gpkg", "mercados")
exportar_camada(parques,         "dados/05_areas_verdes_belem.gpkg", "parques")
exportar_camada(pontos_onibus,   "dados/06_transporte_belem.gpkg", "pontos_onibus")
exportar_camada(rios,            "dados/07_hidrografia_belem.gpkg", "rios")
exportar_camada(portos,          "dados/08_portos_belem.gpkg", "portos")


# ---------------------------------------------------------
# 6.2 Arquivo único com todas as camadas
# ---------------------------------------------------------
arquivo_completo <- "dados/BELEM_OSM_COMPLETO.gpkg"

if (file.exists(arquivo_completo)) file.remove(arquivo_completo)

cat("\n  Criando arquivo completo...\n")
exportar_camada(vias_principais, arquivo_completo, "vias_principais")
exportar_camada(hospitais,       arquivo_completo, "hospitais")
exportar_camada(escolas,         arquivo_completo, "escolas")
exportar_camada(restaurantes,    arquivo_completo, "restaurantes")
exportar_camada(farmacias,       arquivo_completo, "farmacias")
exportar_camada(mercados,        arquivo_completo, "mercados")
exportar_camada(parques,         arquivo_completo, "parques")
exportar_camada(pontos_onibus,   arquivo_completo, "pontos_onibus")
exportar_camada(rios,            arquivo_completo, "rios")
exportar_camada(portos,          arquivo_completo, "portos")



# =========================================================
# 7. RELATÓRIO FINAL
# =========================================================

cat("\n", rep("=", 60), "\n", sep = "")
cat("  RELATÓRIO FINAL\n")
cat(rep("=", 60), "\n\n", sep = "")

# Contadores
n_vias      <- if (!is.null(lin_belem)) nrow(lin_belem) else 0
n_hospitais <- if (!is.null(hospitais)) nrow(hospitais) else 0
n_escolas   <- if (!is.null(escolas)) nrow(escolas) else 0
n_parques   <- if (!is.null(parques)) nrow(parques) else 0
n_rios      <- if (!is.null(rios)) nrow(rios) else 0

cat("🗺️  DADOS BAIXADOS:\n")
cat(paste("   • Vias:", n_vias, "\n"))
cat(paste("   • Hospitais:", n_hospitais, "\n"))
cat(paste("   • Escolas:", n_escolas, "\n"))
cat(paste("   • Parques:", n_parques, "\n"))
cat(paste("   • Rios:", n_rios, "\n"))

cat("\n  ARQUIVOS GERADOS:\n")
cat(paste("   • Pasta dados/: GeoPackages para QGIS\n"))
cat(paste("   • Pasta mapas/: Visualizações em PNG\n"))
cat(paste("   • Arquivo completo:", basename(arquivo_completo), "\n"))

cat("\n  SISTEMA DE REFERÊNCIA:\n")
cat(paste("   • EPSG:", CRS_UTM22S, "\n"))
cat(paste("   • Nome: SIRGAS 2000 / UTM zone 22S\n"))
cat(paste("   • Adequado para: Belém e região\n"))

cat("\n", rep("=", 60), "\n", sep = "")
cat("  PROCESSAMENTO CONCLUÍDO COM SUCESSO!\n")
cat(rep("=", 60), "\n\n", sep = "")

cat("  PRÓXIMOS PASSOS:\n")
cat("   1. Abrir os arquivos .gpkg no QGIS\n")
cat("   2. Verificar os mapas gerados em mapas/\n")
cat("   3. Ajustar simbologia e criar layouts\n")
cat("\n")
